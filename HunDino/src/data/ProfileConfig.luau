-- Studio always uses a separate store. Never point tests at live account data.
return {
 StoreName="HunDinoProfiles_v1",
 StudioStoreName="HunDinoProfiles_Studio_v1",
 Scope="accounts",
 AutoSaveSeconds=30,
 DebounceSeconds=2,
 LeaseSeconds=120,
 RetrySeconds=10,
 -- Only for explicit Studio QA. Native saved configuration must remain false.
 StudioMemoryTest=false,
 -- Explicit opt-in in HunDino_SaveGame only. Published places keep using DataStore.
 StudioLocalFileEnabled=false,
}
