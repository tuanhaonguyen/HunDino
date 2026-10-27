"""Patch source text only. Roblox Studio owns native place saving."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parent.parent
BACKUP=ROOT/'backups/inventory-crafting-20261026'
OUT=ROOT/'assets/inventory-crafting'
def once(s,old,new):
    assert s.count(old)==1,(old[:100],s.count(old))
    return s.replace(old,new,1)
def inventory(s):
    start=s.index('\tlabel(craftPage,"Title","CHẾ TẠO"')
    end=s.index('\tlocal equipmentViews=',start)
    s=s[:start]+(ROOT/'assets/ui/InventoryIronTrapRecipe.luau').read_text(encoding='utf-8')+'\n'+s[end:]
    s=once(s,'else specimenView.PreviewWorld:ClearAllChildren();displayedSpecimenKey=nil;refreshItems() end',
      'else specimenView.PreviewWorld:ClearAllChildren();displayedSpecimenKey=nil;refreshItems();if self.Section=="Crafting" then refreshCraft() end end')
    s=once(s,'if (event~="Snapshot" and event~="Open") or type(dto)~="table" then return end','''if event=="Notice" and type(dto)=="string" and panel.Visible and api.Section=="Crafting" then
            craftNotice=dto;craftPendingToken=nil;craftPendingUntil=nil;refreshCraft();return
        end
        if (event~="Snapshot" and event~="Open") or type(dto)~="table" then return end''')
    s=once(s,'itemSnapshot=dto\n\t\tif panel.Visible then api:Refresh() end','''itemSnapshot=dto
        if craftPendingToken and dto.OperationToken~=craftPendingToken then craftPendingToken=nil;craftPendingUntil=nil end
        if panel.Visible and api.Section=="Crafting" and type(dto.Notice)=="string" then craftNotice=dto.Notice end
        if panel.Visible then api:Refresh() end''')
    return s
def service(s):
    s=once(s,'CraftIronTrap={"Craft","CraftTrap"},UpgradeHammer=', 'CraftIronTrap={"Craft","CraftTrap"},InventoryCraftIronTrap={"Craft","CraftTrap"},UpgradeHammer=')
    s=once(s,'local payload=if action=="UpgradeWeapon" and type(token)=="table" then token else nil','''if action=="InventoryCraftIronTrap" and type(token)~="table" then self:Publish(player,"Yêu cầu chế tạo không hợp lệ.");return end
 local payload=if (action=="UpgradeWeapon" or action=="InventoryCraftIronTrap") and type(token)=="table" then token else nil''')
    s=once(s,'if (offer.Context~="Shop" and offer.Context~="Merchant" and offer.Context~="Craft") or not self:_context(player,op[1]) then',
      'if (offer.Context~="Shop" and offer.Context~="Merchant" and offer.Context~="Craft" and not (action=="InventoryCraftIronTrap" and offer.Context=="Inventory")) or not self:_context(player,op[1]) then')
    s=once(s,'"Đến bàn chế tạo ở base của bạn, cất vũ khí để nâng cấp."', '"Đến bàn chế tạo ở base của bạn, cất vũ khí để chế tạo hoặc nâng cấp."')
    return s
if __name__=='__main__':
    OUT.mkdir(exist_ok=True)
    rows=json.loads((BACKUP/'saved-sources.json').read_text(encoding='utf-8'))
    patches={rows[0]['Path']:inventory,rows[1]['Path']:service}
    plan=[]
    for row in rows:
        path=ROOT/row['File'];source=path.read_text(encoding='utf-8-sig')
        backup=BACKUP/row['File'].replace('/','__')
        assert not backup.exists(),'Patch already prepared; preserve original backup'
        patched=patches[row['Path']](source)
        backup.write_text(source,encoding='utf-8');path.write_text(patched,encoding='utf-8')
        native=patches[row['Path']](row['Source'])
        file='assets/inventory-crafting/'+row['Path']+'.luau'
        (ROOT/file).write_text(native,encoding='utf-8')
        plan.append(dict(Path=row['Path'],File=file,Source=native,Baseline=row['Source'],Before=row['Source']))
    (OUT/'install.json').write_text(json.dumps(plan,ensure_ascii=False),encoding='utf-8')
    print('Prepared inventory recipe and secure inventory craft request; native place untouched')
