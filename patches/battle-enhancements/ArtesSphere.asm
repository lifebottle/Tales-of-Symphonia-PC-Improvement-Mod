// ArtesSphere / CT 2109: Detect Battle Menu
// Table script authors: sdail; see README.md for provenance and port fixes.
// Native x86 port of selected TOS NoTSFix v26.9.1 entries.
[ENABLE]
// Detect Battle Menu
alloc(mem_payload_e2109_Mem_BattleMenu_Enter,0xc8)
// Detect Battle Menu
alloc(mem_payload_e2109_Mem_BattleMenu_Exit,0xc8)
// Detect Battle Menu
alloc(mem_payload_BattleMenu,0x1)
// Detect Battle Menu
assert(TOS.exe+0x5d8a3,c6 86 ce 93 00 00 01)
// Detect Battle Menu
assert(TOS.exe+0x5d8f7,c6 86 ce 93 00 00 00)
// Detect Shortcut State
alloc(mem_payload_e2118_Mem_ShortcutState_Exit,0xc8)
// Detect Shortcut State
alloc(mem_payload_e2118_Mem_ShortcutState_Enter,0xc8)
// Detect Shortcut State
alloc(mem_payload_ShortcutState,0x1)
// Detect Shortcut State
assert(TOS.exe+0x124c02,66 89 15 c8 3a b1 00)
// Detect Shortcut State
assert(TOS.exe+0x1255e6,c6 05 c9 3a b1 00 05)
// Detect Artes Menu State
alloc(mem_payload_e2120_Mem_ArtesMenu_Enter,0xc8)
// Detect Artes Menu State
alloc(mem_payload_e2120_Mem_ArtesMenu_Exit,0xc8)
// Detect Artes Menu State
alloc(mem_payload_e2120_Mem_ArtesMenuHMN_Exit,0xc8)
// Detect Artes Menu State
alloc(mem_payload_e2120_Mem_ArtesMenuCPU_Exit,0xc8)
// Detect Artes Menu State
alloc(mem_payload_ArtesMenu,0x1)
// Detect Artes Menu State
assert(TOS.exe+0x124d98,66 c7 05 c4 3a b1 00 00 00)
// Detect Artes Menu State
assert(TOS.exe+0x124eb3,c6 05 c5 3a b1 00 04)
// Detect Artes Menu State
assert(TOS.exe+0x125617,c6 05 c5 3a b1 00 04)
// Detect Artes Menu State
assert(TOS.exe+0x1265ad,c6 05 c5 3a b1 00 04)
// Detect Unison Menu State
alloc(mem_payload_e2122_Mem_UnisonMenu_Enter,0xc8)
// Detect Unison Menu State
alloc(mem_payload_e2122_Mem_UnisonMenu_Exit,0xc8)
// Detect Unison Menu State
alloc(mem_payload_UnisonMenu,0x1)
// Detect Unison Menu State
assert(TOS.exe+0x127b3a,66 c7 05 18 19 c3 01 00 00)
// Detect Unison Menu State
assert(TOS.exe+0x1280be,c6 05 19 19 c3 01 04)
// Detect Character State
alloc(mem_payload_e2272_Mem_CharState,0x250)
// Detect Character State
alloc(mem_payload_CurrentState,0x4)
// Detect Character State
assert(TOS.exe+0x497aa,8a 87 b0 01 00 00)
// Inputs [NEW]
alloc(mem_payload_e2444_Mem_ButtonInputs,0x4000)
// Inputs [NEW]
alloc(mem_payload_ControlID,0x1)
// Inputs [NEW]
alloc(mem_payload_UnisonID,0x2)
// Inputs [NEW]
alloc(mem_payload_LoopCounter,0x2)
// Inputs [NEW]
alloc(mem_payload_MainControls,0x2)
// Inputs [NEW]
alloc(mem_payload_StoredControls,0x64)
// Inputs [NEW]
alloc(mem_payload_PageSwitch,0x2)
// Inputs [NEW]
alloc(mem_payload_FreeRunActive,0x1)
// Inputs [NEW]
alloc(mem_payload_LockA,0x4)
// Inputs [NEW]
alloc(mem_payload_LockB,0x4)
// Inputs [NEW]
alloc(mem_payload_LockX,0x4)
// Inputs [NEW]
alloc(mem_payload_LockRS,0x4)
// Inputs [NEW]
alloc(mem_payload_CharBuffer,0x2)
// Inputs [NEW]
alloc(mem_payload_PageCache,0x2)
// Inputs [NEW]
assert(TOS.exe+0x211a73,89 4e 10 8b d1)
// Arte Page Indicator
alloc(mem_payload_e2679_Mem_ArtePageIndicator,0x2000)
// Arte Page Indicator
alloc(mem_payload_PageString,0x40)
// Arte Page Indicator
assert(TOS.exe+0x120b83,e8 c8 16 01 00)
// Unison Arte Page Indicator
alloc(mem_payload_e2687_Mem_UnisonPageIndicator,0x2000)
// Unison Arte Page Indicator
assert(TOS.exe+0x1270f0,e8 5b b1 00 00)
// Arte Sphere Set Buffer (1st Attack)
alloc(mem_payload_e2473_Mem_BattleArteBuffer,0x2000)
// Arte Sphere Set Buffer (1st Attack)
assert(TOS.exe+0x75d2c,8b b0 70 90 00 00)
// Arte Sphere Set Buffer (Combo)
alloc(mem_payload_e2476_Mem_BattleArteBufferCombo,0x2000)
// Arte Sphere Set Buffer (Combo)
assert(TOS.exe+0x346a5,85 88 70 90 00 00)
// Arte Sphere Set Buffer (Air)
alloc(mem_payload_e2475_Mem_BattleArteBufferAir,0x2000)
// Arte Sphere Set Buffer (Air)
assert(TOS.exe+0x75a1f,8b 81 70 90 00 00)
// Arte Sphere Check (1st Attack)
alloc(mem_payload_e2477_Mem_BattleArte,0x2000)
// Arte Sphere Check (1st Attack)
assert(TOS.exe+0x75d3f,66 83 bc 4b d8 00 00 00 00)
// Arte Sphere Use (1st Attack)
alloc(mem_payload_e2478_Mem_BattleArteSelect,0x2000)
// Arte Sphere Use (1st Attack)
assert(TOS.exe+0x76129,0f b7 84 4a d8 00 00 00)
// Arte Sphere Check (Combo)
alloc(mem_payload_e2479_Mem_BattleArteCombo,0x2000)
// Arte Sphere Check (Combo)
assert(TOS.exe+0x346be,66 83 bc 4a d8 00 00 00 00)
// Arte Sphere Use (Combo)
alloc(mem_payload_e2480_Mem_BattleArteSelectCombo,0x2000)
// Arte Sphere Use (Combo)
assert(TOS.exe+0x34811,0f b7 9c 50 d8 00 00 00)
// Arte Sphere Use (Air Attack)
alloc(mem_payload_e2481_Mem_BattleArteSelectAir,0x2000)
// Arte Sphere Use (Air Attack)
assert(TOS.exe+0x75a5f,0f b7 84 4a d8 00 00 00)
// Arte Sphere Use Char/Shortcut 1 (Command)
alloc(mem_payload_e2456_Mem_BattleArteCharCommand1,0x2000)
// Arte Sphere Use Char/Shortcut 1 (Command)
assert(TOS.exe+0x751d9,0f b6 8f e4 00 00 00)
// Arte Sphere Use Char/Shortcut 1 (Command)
assert(TOS.exe+0x751e6,0f b7 bf e0 00 00 00)
// Arte Sphere Use Char/Shortcut 2 (Command)
alloc(mem_payload_e2549_Mem_BattleArteCharCommand2,0x2000)
// Arte Sphere Use Char/Shortcut 2 (Command)
assert(TOS.exe+0x75214,0f b6 87 e5 00 00 00)
// Arte Sphere Use Char/Shortcut 2 (Command)
assert(TOS.exe+0x75221,0f b7 bf e2 00 00 00)
// Arte Sphere Check Char 1 A (1st Attack)
alloc(mem_payload_e2452_Mem_BattleArteChar1_A,0x2000)
// Arte Sphere Check Char 1 A (1st Attack)
assert(TOS.exe+0x75d62,38 8b e4 00 00 00)
// Arte Sphere Check Char 2 A (1st Attack)
alloc(mem_payload_e2553_Mem_BattleArteChar2_A,0x2000)
// Arte Sphere Check Char 2 A (1st Attack)
assert(TOS.exe+0x75d82,38 8b e5 00 00 00)
// Arte Sphere Use Shortcut 1 B (1st Attack)
alloc(mem_payload_e2554_Mem_BattleArteSelectShortcut1_B,0x2000)
// Arte Sphere Use Shortcut 1 B (1st Attack)
assert(TOS.exe+0x7614e,0f b7 b0 e0 00 00 00)
// Arte Sphere Use Shortcut 1 B (1st Attack)
assert(TOS.exe+0x76163,38 88 e4 00 00 00)
// Arte Sphere Use Shortcut 2 B (1st Attack)
alloc(mem_payload_e2552_Mem_BattleArteSelectShortcut2_B,0x2000)
// Arte Sphere Use Shortcut 2 B (1st Attack)
assert(TOS.exe+0x7618f,0f b7 b0 e2 00 00 00)
// Arte Sphere Use Shortcut 2 B (1st Attack)
assert(TOS.exe+0x761a4,38 88 e5 00 00 00)
// Arte Sphere Check Char/Shortcut (Combo)
alloc(mem_payload_e2459_Mem_BattleArteChar1Combo,0x2000)
// Arte Sphere Check Char/Shortcut (Combo)
assert(TOS.exe+0x346fc,38 98 e4 00 00 00)
// Arte Sphere Check Char/Shortcut (Combo)
assert(TOS.exe+0x3470c,66 83 b8 e0 00 00 00 00)
// Arte Sphere Check Char/Shortcut (Combo)
assert(TOS.exe+0x3471d,38 98 e5 00 00 00)
// Arte Sphere Check Char/Shortcut (Combo)
assert(TOS.exe+0x3472d,66 83 b8 e2 00 00 00 00)
// Arte Sphere Check Char/Shortcut 1 (Air)
alloc(mem_payload_e2474_Mem_BattleArteChar1Air,0x2000)
// Arte Sphere Check Char/Shortcut 1 (Air)
assert(TOS.exe+0x75a9f,38 90 e4 00 00 00)
// Arte Sphere Check Char/Shortcut 1 (Air)
assert(TOS.exe+0x75aaf,0f b7 80 e0 00 00 00)
// Arte Sphere Check Char/Shortcut 2 (Air)
alloc(mem_payload_e2555_Mem_BattleArteChar2Air,0x2000)
// Arte Sphere Check Char/Shortcut 2 (Air)
assert(TOS.exe+0x75ad5,38 88 e5 00 00 00)
// Arte Sphere Check Char/Shortcut 2 (Air)
assert(TOS.exe+0x75af4,0f b7 80 e2 00 00 00)
// Arte Sphere Use Unison
alloc(mem_payload_e2569_Mem_BattleArteUnison,0x2000)
// Arte Sphere Use Unison
assert(TOS.exe+0x722f8,0f b7 8c 48 d8 00 00 00)
// Trigger Fix
assert(TOS.exe+0x2111d7,3a d3 75 07 bf 00 04 00 00)
// Trigger Fix
assert(TOS.exe+0x2111eb,3a c3 75 05 bb 00 08 00 00)
// R-Stick Shortcuts (Rebinds LT and RT)
alloc(mem_payload_e2558_Mem_DisableRStickX,0xc8)
// R-Stick Shortcuts (Rebinds LT and RT)
alloc(mem_payload_e2558_Mem_DisableRStickY,0xc8)
// R-Stick Shortcuts (Rebinds LT and RT)
assert(TOS.exe+0x211abe,89 51 20 8b 50 2c)
// R-Stick Shortcuts (Rebinds LT and RT)
assert(TOS.exe+0x211ac4,89 51 24 8b 50 30)
// Remove Shortcut Fix (Fixes Removing a Shortcut Arte from the Menu)
alloc(mem_payload_e2559_Mem_RemoveShortcutFix,0xc8)
// Remove Shortcut Fix (Fixes Removing a Shortcut Arte from the Menu)
assert(TOS.exe+0x125348,66 89 17 c7 45 f8 1c 00 00 00)
// R-Stick Shortcut Icons
assert(TOS.exe+0x122417,c7 44 24 68 1c 00 16 00)
// R-Stick Shortcut Icons
assert(TOS.exe+0x1223ff,c7 44 24 5c 1b 00 15 00)
assert(TOS.exe+0x346e9,f7 c1 00 0c 00 00 74 4d 8a 9e 22 13)
assert(TOS.exe+0x75a7b,0f b6 87 21 13 00 00 83 e0 03 8b 0c)
assert(TOS.exe+0x75d4f,f7 c2 00 08 00 00 74 18 8a 8f 22 13)
assert(TOS.exe+0x12e5b0,55 8b ec 51 66 8b c1 66 c1 e8 08 0f)
assert(TOS.exe+0x132250,55 8b ec 83 e4 f8 83 ec 0c 53 56 8b)
define(BattleMenu_Enter,TOS.exe+0x5d8a3)
define(BattleMenu_Exit,TOS.exe+0x5d8f7)
define(ShortcutState_Exit,TOS.exe+0x124c02)
define(ShortcutState_Enter,TOS.exe+0x1255e6)
define(ArtesMenu_Enter,TOS.exe+0x124d98)
define(ArtesMenu_Exit,TOS.exe+0x124eb3)
define(ArtesMenuHMN_Exit,TOS.exe+0x125617)
define(ArtesMenuCPU_Exit,TOS.exe+0x1265ad)
define(UnisonMenu_Enter,TOS.exe+0x127b3a)
define(UnisonMenu_Exit,TOS.exe+0x1280be)
define(CharState,TOS.exe+0x497aa)
define(ButtonInputs,TOS.exe+0x211a73)
define(ArtePageIndicator,TOS.exe+0x120b83)
define(UnisonPageIndicator,TOS.exe+0x1270f0)
define(BattleArteBuffer,TOS.exe+0x75d2c)
define(BattleArteBufferCombo,TOS.exe+0x346a5)
define(BattleArteBufferAir,TOS.exe+0x75a1f)
define(BattleArte,TOS.exe+0x75d3f)
define(BattleArteSelect,TOS.exe+0x76129)
define(BattleArteCombo,TOS.exe+0x346be)
define(BattleArteSelectCombo,TOS.exe+0x34811)
define(BattleArteSelectAir,TOS.exe+0x75a5f)
define(BattleArteCommand1,TOS.exe+0x751d9)
define(BattleArteCommand2,TOS.exe+0x75214)
define(BattleArteChar1_A,TOS.exe+0x75d62)
define(BattleArteChar2_A,TOS.exe+0x75d82)
define(BattleArteSelectShortcut1_B,TOS.exe+0x7614e)
define(BattleArteSelectShortcut2_B,TOS.exe+0x7618f)
define(BattleArteChar1Combo,TOS.exe+0x346fc)
define(BattleArteChar1Air,TOS.exe+0x75a9f)
define(BattleArteChar2Air,TOS.exe+0x75ad5)
define(BattleArteUnison,TOS.exe+0x722f8)
define(LeftTriggerFix,TOS.exe+0x2111d7)
define(RightTriggerFix,TOS.exe+0x2111eb)
define(DisableRStickX,TOS.exe+0x211abe)
define(DisableRStickY,TOS.exe+0x211ac4)
define(RemoveShortcutFix,TOS.exe+0x125348)
define(ManualOverlimit,TOS.exe+0x3912c)
define(DisableOverlimitPartyLimit,TOS.exe+0x3913c)
define(OverlimitPortrait,TOS.exe+0x4e186)
define(OverLimitVictoryEmpty,TOS.exe+0x80738)
define(MathFunctions,TOS.exe+0x2e7cf0)
define(StickWalkCheck,TOS.exe+0x76794)
define(FreeRun2,TOS.exe+0x84cc9)
define(MoveSideCheck,TOS.exe+0x84d15)
define(BattleState,TOS.exe+0x718652)
define(OverLimitVictoryEnd,TOS.exe+0x80743)
define(game_2727b,TOS.exe+0x2727b)
define(game_6d2edc,TOS.exe+0x6d2edc)
define(game_2722e,TOS.exe+0x2722e)
define(ct_base_ct_2692_patch_2,TOS.exe+0x2727b)
define(e2692_site_3,TOS.exe+0x2727b)
registersymbol(e2109_Mem_BattleMenu_Enter)
registersymbol(e2109_Mem_BattleMenu_Exit)
registersymbol(BattleMenu)
registersymbol(e2109_Code_BattleMenu_Enter)
registersymbol(e2109_Ret_BattleMenu_Enter)
registersymbol(e2109_Code_BattleMenu_Exit)
registersymbol(e2109_Ret_BattleMenu_Exit)
registersymbol(e2118_Mem_ShortcutState_Exit)
registersymbol(e2118_Mem_ShortcutState_Enter)
registersymbol(ShortcutState)
registersymbol(e2118_Code_ShortcutState_Exit)
registersymbol(e2118_Ret_ShortcutState_Exit)
registersymbol(e2118_Code_ShortcutState_Enter)
registersymbol(e2118_Ret_ShortcutState_Enter)
registersymbol(e2120_Mem_ArtesMenu_Enter)
registersymbol(e2120_Mem_ArtesMenu_Exit)
registersymbol(e2120_Mem_ArtesMenuHMN_Exit)
registersymbol(e2120_Mem_ArtesMenuCPU_Exit)
registersymbol(ArtesMenu)
registersymbol(e2120_Code_ArtesMenu_Enter)
registersymbol(e2120_Ret_ArtesMenu_Enter)
registersymbol(e2120_Code_ArtesMenu_Exit)
registersymbol(e2120_Ret_ArtesMenu_Exit)
registersymbol(e2120_Code_ArtesMenuHMN_Exit)
registersymbol(e2120_Ret_ArtesMenuHMN_Exit)
registersymbol(e2120_Code_ArtesMenuCPU_Exit)
registersymbol(e2120_Ret_ArtesMenuCPU_Exit)
registersymbol(e2122_Mem_UnisonMenu_Enter)
registersymbol(e2122_Mem_UnisonMenu_Exit)
registersymbol(UnisonMenu)
registersymbol(e2122_Code_UnisonMenu_Enter)
registersymbol(e2122_Ret_UnisonMenu_Enter)
registersymbol(e2122_Code_UnisonMenu_Exit)
registersymbol(e2122_Ret_UnisonMenu_Exit)
registersymbol(e2272_Mem_CharState)
registersymbol(CurrentState)
registersymbol(e2272_Code_CharState)
registersymbol(e2272_Ret_CharState)
registersymbol(e2444_Mem_ButtonInputs)
registersymbol(ControlID)
registersymbol(UnisonID)
registersymbol(LoopCounter)
registersymbol(MainControls)
registersymbol(StoredControls)
registersymbol(PageSwitch)
registersymbol(FreeRunActive)
registersymbol(LockA)
registersymbol(LockB)
registersymbol(LockX)
registersymbol(LockRS)
registersymbol(CharBuffer)
registersymbol(PageCache)
registersymbol(e2444_ResetPage)
registersymbol(e2444_PageCheck)
registersymbol(e2444_ResetAllPages)
registersymbol(e2444_UnisonPageCheck)
registersymbol(e2444_ArtesPageCheck)
registersymbol(e2444_MergePageCheck)
registersymbol(e2444_SkipResetAllPages)
registersymbol(e2444_Func_GetInputs)
registersymbol(e2444_GetInputsLoop)
registersymbol(e2444_ReleasedButton)
registersymbol(e2444_GetInputsEnd)
registersymbol(e2444_Func_ResetPage)
registersymbol(e2444_Func_ResetAllPages)
registersymbol(e2444_Func_UpdatePages)
registersymbol(e2444_UpdatePagesLoopMain)
registersymbol(e2444_UpdatePagesLoopSub)
registersymbol(e2444_SkipUpdatePage)
registersymbol(e2444_Func_GetPartySlot)
registersymbol(e2444_Func_GetController)
registersymbol(e2444_IncID)
registersymbol(e2444_Code_ButtonInputs)
registersymbol(e2444_StateCheck)
registersymbol(e2444_LockChecks)
registersymbol(e2444_UnlockA)
registersymbol(e2444_LockCheckB)
registersymbol(e2444_UnlockB)
registersymbol(e2444_LockCheckX)
registersymbol(e2444_UnlockX)
registersymbol(e2444_UnlockChecks)
registersymbol(e2444_UnlockCheckB)
registersymbol(e2444_UnlockCheckX)
registersymbol(e2444_UnlockCheckRS)
registersymbol(e2444_UpdateLocks)
registersymbol(e2444_UpdateLockB)
registersymbol(e2444_UpdateLockX)
registersymbol(e2444_UnlockAll)
registersymbol(e2444_DebugTest)
registersymbol(e2444_Ret_ButtonInputs)
registersymbol(e2679_Mem_ArtePageIndicator)
registersymbol(PageString)
registersymbol(e2679_PageSub)
registersymbol(e2679_Code_ArtePageIndicator)
registersymbol(e2679_Ret_ArtePageIndicator)
registersymbol(e2687_Mem_UnisonPageIndicator)
registersymbol(e2687_PageSub)
registersymbol(e2687_Code_UnisonPageIndicator)
registersymbol(e2687_Ret_UnisonPageIndicator)
registersymbol(e2473_Mem_BattleArteBuffer)
registersymbol(e2473_ArteSphereCheck)
registersymbol(e2473_QuickTest)
registersymbol(e2473_Code_BattleArteBuffer)
registersymbol(e2473_Ret_BattleArteBuffer)
registersymbol(e2476_Mem_BattleArteBufferCombo)
registersymbol(e2476_ArteSphereCheck)
registersymbol(e2476_QuickTest)
registersymbol(e2476_Code_BattleArteBufferCombo)
registersymbol(e2476_Ret_BattleArteBufferCombo)
registersymbol(e2475_Mem_BattleArteBufferAir)
registersymbol(e2475_ArteSphereCheck)
registersymbol(e2475_QuickTest)
registersymbol(e2475_Code_BattleArteBufferAir)
registersymbol(e2475_Ret_BattleArteBufferAir)
registersymbol(e2477_Mem_BattleArte)
registersymbol(e2477_ArteSphereCheck)
registersymbol(e2477_Ret_BattleArte)
registersymbol(e2478_Mem_BattleArteSelect)
registersymbol(e2478_ArteSphereCheck)
registersymbol(e2478_Ret_BattleArteSelect)
registersymbol(e2479_Mem_BattleArteCombo)
registersymbol(e2479_ArteSphereCheck)
registersymbol(e2479_Ret_BattleArteCombo)
registersymbol(e2480_Mem_BattleArteSelectCombo)
registersymbol(e2480_ArteSphereCheck)
registersymbol(e2480_Ret_BattleArteSelectCombo)
registersymbol(e2481_Mem_BattleArteSelectAir)
registersymbol(e2481_ArteSphereCheck)
registersymbol(e2481_Ret_BattleArteSelectAir)
registersymbol(e2456_Mem_BattleArteCharCommand1)
registersymbol(e2456_ArteSphereCheck)
registersymbol(e2456_QuickTest)
registersymbol(e2456_Mem_BattleArteShortcutCommand1)
registersymbol(e2456_ArteSphereCheck2)
registersymbol(e2456_Ret_BattleArteCharCommand1)
registersymbol(e2456_Ret_BattleArteShortcutCommand1)
registersymbol(e2549_Mem_BattleArteCharCommand2)
registersymbol(e2549_ArteSphereCheck)
registersymbol(e2549_QuickTest)
registersymbol(e2549_Mem_BattleArteShortcutCommand2)
registersymbol(e2549_ArteSphereCheck2)
registersymbol(e2549_Ret_BattleArteCharCommand2)
registersymbol(e2549_Ret_BattleArteShortcutCommand2)
registersymbol(e2452_Mem_BattleArteChar1_A)
registersymbol(e2452_ArteSphereCheck)
registersymbol(e2452_Ret_BattleArteChar1_A)
registersymbol(e2553_Mem_BattleArteChar2_A)
registersymbol(e2553_ArteSphereCheck)
registersymbol(e2553_Ret_BattleArteChar2_A)
registersymbol(e2554_Mem_BattleArteSelectShortcut1_B)
registersymbol(e2554_ArteSphereCheck)
registersymbol(e2554_Mem_BattleArteChar1_B)
registersymbol(e2554_ArteSphereCheck2)
registersymbol(e2554_Ret_BattleArteSelectShortcut1_B)
registersymbol(e2554_Ret_BattleArteChar1_B)
registersymbol(e2552_Mem_BattleArteSelectShortcut2_B)
registersymbol(e2552_ArteSphereCheck)
registersymbol(e2552_Mem_BattleArteChar2_B)
registersymbol(e2552_ArteSphereCheck2)
registersymbol(e2552_Ret_BattleArteSelectShortcut2_B)
registersymbol(e2552_Ret_BattleArteChar2_B)
registersymbol(e2459_Mem_BattleArteChar1Combo)
registersymbol(e2459_ArteSphereCheck)
registersymbol(e2459_Mem_BattleArteShortcut1Combo)
registersymbol(e2459_ArteSphereCheck2)
registersymbol(e2459_Mem_BattleArteChar2Combo)
registersymbol(e2459_ArteSphereCheck3)
registersymbol(e2459_Mem_BattleArteShortcut2Combo)
registersymbol(e2459_ArteSphereCheck4)
registersymbol(e2459_Ret_BattleArteChar1Combo)
registersymbol(e2459_Ret_BattleArteShortcut1Combo)
registersymbol(e2459_Ret_BattleArteChar2Combo)
registersymbol(e2459_Ret_BattleArteShortcut2Combo)
registersymbol(e2474_Mem_BattleArteChar1Air)
registersymbol(e2474_ArteSphereCheck)
registersymbol(e2474_Mem_BattleArteShortcut1Air)
registersymbol(e2474_ArteSphereCheck2)
registersymbol(e2474_Ret_BattleArteChar1Air)
registersymbol(e2474_Ret_BattleArteShortcut1Air)
registersymbol(e2555_Mem_BattleArteChar2Air)
registersymbol(e2555_ArteSphereCheck)
registersymbol(e2555_Mem_BattleArteShortcut2Air)
registersymbol(e2555_ArteSphereCheck2)
registersymbol(e2555_Ret_BattleArteChar2Air)
registersymbol(e2555_Ret_BattleArteShortcut2Air)
registersymbol(e2569_Mem_BattleArteUnison)
registersymbol(e2569_ArteSphereCheck)
registersymbol(e2569_Ret_BattleArteUnison)
registersymbol(e2558_Mem_DisableRStickX)
registersymbol(e2558_Mem_DisableRStickY)
registersymbol(e2558_Code_DisableRStickX)
registersymbol(e2558_Ret_DisableRStickX)
registersymbol(e2558_NotLocked)
registersymbol(e2558_ObtainedABS)
registersymbol(e2558_TestLow)
registersymbol(e2558_ReassignEnd)
registersymbol(e2558_StickDeadzone)
registersymbol(e2558_ClearStickY)
registersymbol(e2558_Code_DisableRStickY)
registersymbol(e2558_Ret_DisableRStickY)
registersymbol(e2559_Mem_RemoveShortcutFix)
registersymbol(e2559_Code_RemoveShortcutFix)
registersymbol(e2559_Ret_RemoveShortcutFix)


// Detect Battle Menu
mem_payload_e2109_Mem_BattleMenu_Enter:
e2109_Mem_BattleMenu_Enter:

// Detect Battle Menu
mem_payload_e2109_Mem_BattleMenu_Exit:
e2109_Mem_BattleMenu_Exit:

// Detect Battle Menu
mem_payload_BattleMenu:
BattleMenu:
  db 00

// Detect Battle Menu
mem_payload_e2109_Mem_BattleMenu_Enter:
  mov byte ptr [BattleMenu],0x1
e2109_Code_BattleMenu_Enter:
  mov byte ptr [esi+0x000093CE],0x01
  jmp e2109_Ret_BattleMenu_Enter

// Detect Battle Menu
TOS.exe+0x5d8a3:
  jmp e2109_Mem_BattleMenu_Enter
  nop #2
e2109_Ret_BattleMenu_Enter:

// Detect Battle Menu
mem_payload_e2109_Mem_BattleMenu_Exit:
  mov byte ptr [BattleMenu],0x0
e2109_Code_BattleMenu_Exit:
  mov byte ptr [esi+0x000093CE],0x00
  jmp e2109_Ret_BattleMenu_Exit

// Detect Battle Menu
TOS.exe+0x5d8f7:
  jmp e2109_Mem_BattleMenu_Exit
  nop #2
e2109_Ret_BattleMenu_Exit:

// ArtesSphere / CT 2235: Detect Battle State New

// ArtesSphere / CT 2118: Detect Shortcut State

// Detect Shortcut State
mem_payload_e2118_Mem_ShortcutState_Exit:
e2118_Mem_ShortcutState_Exit:

// Detect Shortcut State
mem_payload_e2118_Mem_ShortcutState_Enter:
e2118_Mem_ShortcutState_Enter:

// Detect Shortcut State
mem_payload_ShortcutState:
ShortcutState:
  db 00

// Detect Shortcut State
mem_payload_e2118_Mem_ShortcutState_Exit:
  mov byte ptr [ShortcutState],0x0
e2118_Code_ShortcutState_Exit:
  mov [TOS.exe+0x713AC8],dx
  jmp e2118_Ret_ShortcutState_Exit

// Detect Shortcut State
TOS.exe+0x124c02:
  jmp e2118_Mem_ShortcutState_Exit
  nop #2
e2118_Ret_ShortcutState_Exit:

// Detect Shortcut State
mem_payload_e2118_Mem_ShortcutState_Enter:
  mov byte ptr [ShortcutState],0x1
e2118_Code_ShortcutState_Enter:
  mov byte ptr [TOS.exe+0x713AC9],0x05
  jmp e2118_Ret_ShortcutState_Enter

// Detect Shortcut State
TOS.exe+0x1255e6:
  jmp e2118_Mem_ShortcutState_Enter
  nop #2
e2118_Ret_ShortcutState_Enter:

// ArtesSphere / CT 2120: Detect Artes Menu State

// Detect Artes Menu State
mem_payload_e2120_Mem_ArtesMenu_Enter:
e2120_Mem_ArtesMenu_Enter:

// Detect Artes Menu State
mem_payload_e2120_Mem_ArtesMenu_Exit:
e2120_Mem_ArtesMenu_Exit:

// Detect Artes Menu State
mem_payload_e2120_Mem_ArtesMenuHMN_Exit:
e2120_Mem_ArtesMenuHMN_Exit:

// Detect Artes Menu State
mem_payload_e2120_Mem_ArtesMenuCPU_Exit:
e2120_Mem_ArtesMenuCPU_Exit:

// Detect Artes Menu State
mem_payload_ArtesMenu:
ArtesMenu:
  db 00

// Detect Artes Menu State
mem_payload_e2120_Mem_ArtesMenu_Enter:
  mov byte ptr [ArtesMenu],0x1
e2120_Code_ArtesMenu_Enter:
  mov word ptr [TOS.exe+0x713AC4],0x0000
  jmp e2120_Ret_ArtesMenu_Enter

// Detect Artes Menu State
TOS.exe+0x124d98:
  jmp e2120_Mem_ArtesMenu_Enter
  nop #4
e2120_Ret_ArtesMenu_Enter:

// Detect Artes Menu State
mem_payload_e2120_Mem_ArtesMenu_Exit:
  mov byte ptr [ArtesMenu],0x0
e2120_Code_ArtesMenu_Exit:
  mov byte ptr [TOS.exe+0x713AC5],0x04
  jmp e2120_Ret_ArtesMenu_Exit

// Detect Artes Menu State
TOS.exe+0x124eb3:
  jmp e2120_Mem_ArtesMenu_Exit
  nop #2
e2120_Ret_ArtesMenu_Exit:

// Detect Artes Menu State
mem_payload_e2120_Mem_ArtesMenuHMN_Exit:
  mov byte ptr [ArtesMenu],0x0
e2120_Code_ArtesMenuHMN_Exit:
  mov byte ptr [TOS.exe+0x713AC5],0x04
  jmp e2120_Ret_ArtesMenuHMN_Exit

// Detect Artes Menu State
TOS.exe+0x125617:
  jmp e2120_Mem_ArtesMenuHMN_Exit
  nop #2
e2120_Ret_ArtesMenuHMN_Exit:

// Detect Artes Menu State
mem_payload_e2120_Mem_ArtesMenuCPU_Exit:
  mov byte ptr [ArtesMenu],0x0
e2120_Code_ArtesMenuCPU_Exit:
  mov byte ptr [TOS.exe+0x713AC5],0x04
  jmp e2120_Ret_ArtesMenuCPU_Exit

// Detect Artes Menu State
TOS.exe+0x1265ad:
  jmp e2120_Mem_ArtesMenuCPU_Exit
  nop #2
e2120_Ret_ArtesMenuCPU_Exit:

// ArtesSphere / CT 2122: Detect Unison Menu State

// Detect Unison Menu State
mem_payload_e2122_Mem_UnisonMenu_Enter:
e2122_Mem_UnisonMenu_Enter:

// Detect Unison Menu State
mem_payload_e2122_Mem_UnisonMenu_Exit:
e2122_Mem_UnisonMenu_Exit:

// Detect Unison Menu State
mem_payload_UnisonMenu:
UnisonMenu:
  db 00

// Detect Unison Menu State
mem_payload_e2122_Mem_UnisonMenu_Enter:
  mov byte ptr [UnisonMenu],0x1
e2122_Code_UnisonMenu_Enter:
  mov word ptr [TOS.exe+0x1831918],0x0000
  jmp e2122_Ret_UnisonMenu_Enter

// Detect Unison Menu State
TOS.exe+0x127b3a:
  jmp e2122_Mem_UnisonMenu_Enter
  nop #4
e2122_Ret_UnisonMenu_Enter:

// Detect Unison Menu State
mem_payload_e2122_Mem_UnisonMenu_Exit:
  mov byte ptr [UnisonMenu],0x0
e2122_Code_UnisonMenu_Exit:
  mov byte ptr [TOS.exe+0x1831919],0x04
  jmp e2122_Ret_UnisonMenu_Exit

// Detect Unison Menu State
TOS.exe+0x1280be:
  jmp e2122_Mem_UnisonMenu_Exit
  nop #2
e2122_Ret_UnisonMenu_Exit:

// ArtesSphere / CT 2272: Detect Character State

// Detect Character State
mem_payload_e2272_Mem_CharState:
e2272_Mem_CharState:

// Detect Character State
mem_payload_CurrentState:
CurrentState:
  db 00, 00, 00, 00

// Detect Character State
mem_payload_e2272_Mem_CharState:
  mov al,[edi+0x1B0]
  push edx
  movzx edx,byte ptr [edi+0x1321]
  and edx,0x03
  mov byte ptr [CurrentState+edx],al
  pop edx
e2272_Code_CharState:
  jmp e2272_Ret_CharState

// Detect Character State
TOS.exe+0x497aa:
  jmp e2272_Mem_CharState
  nop
e2272_Ret_CharState:

// ArtesSphere / CT 2444: Inputs [NEW]

// Inputs [NEW]
mem_payload_e2444_Mem_ButtonInputs:
e2444_Mem_ButtonInputs:

// Inputs [NEW]
mem_payload_ControlID:
ControlID:
  db 00

// Inputs [NEW]
mem_payload_UnisonID:
UnisonID:
  db 00, 00

// Inputs [NEW]
mem_payload_LoopCounter:
LoopCounter:
  db 00, 00

// Inputs [NEW]
mem_payload_MainControls:
MainControls:
  db 00, 00

// Inputs [NEW]
mem_payload_StoredControls:
StoredControls:
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
  db 00, 00, 00, 00

// Inputs [NEW]
mem_payload_PageSwitch:
PageSwitch:
  db 00, 00

// Inputs [NEW]
mem_payload_FreeRunActive:
FreeRunActive:
  db 00

// Inputs [NEW]
mem_payload_LockA:
LockA:
  db 00, 00, 00, 00

// Inputs [NEW]
mem_payload_LockB:
LockB:
  db 00, 00, 00, 00

// Inputs [NEW]
mem_payload_LockX:
LockX:
  db 00, 00, 00, 00

// Inputs [NEW]
mem_payload_LockRS:
LockRS:
  db 00, 00, 00, 00

// Inputs [NEW]
mem_payload_CharBuffer:
CharBuffer:
  db 00, 00

// Inputs [NEW]
mem_payload_PageCache:
PageCache:
  db 00, 00

// Inputs [NEW]
mem_payload_e2444_Mem_ButtonInputs:
// Startup/title-screen calls can precede save-data allocation. Invalid
// controller pointers must not index the four-controller state arrays.
  pushfd
  push eax
  mov eax, DWORD PTR [TOS.exe+0x6d3f68]
  test eax, eax
  jz input_passthrough
  mov eax, ebx
  sub eax, TOS.exe+0xa2de20
  test eax, 0x3f
  jnz input_passthrough
  cmp eax, 0xc0
  ja input_passthrough
  pop eax
  popfd
  push eax
  push esi
  push edi
  sub ebx, TOS.exe+0xA2DE20
  shr ebx,0x6
  mov byte ptr [ControlID],bl
  call e2444_Func_GetInputs
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  cmp byte ptr [edx+0xf4d+ebx],0x0
  pop edx
  je e2444_IncID
  cmp byte ptr [BattleState],0x0
  je e2444_PageCheck
  cmp byte ptr [BattleMenu],0x1
  je e2444_PageCheck
  and word ptr [MainControls],0xF2FF
  jmp e2444_PageCheck
e2444_ResetPage:
  not ebx
  and word ptr [PageSwitch],bx
  call e2444_Func_UpdatePages
  jmp e2444_IncID
e2444_PageCheck:
  cmp byte ptr [ArtesMenu],0x1
  je e2444_ArtesPageCheck
  cmp byte ptr [UnisonMenu],0x1
  je e2444_UnisonPageCheck
e2444_ResetAllPages:
  mov byte ptr [PageCache],cl
  mov word ptr [PageSwitch],0x0
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  cmp word ptr [edx+0x114+0x7E],0x0
  pop edx
  je e2444_IncID
  call e2444_Func_UpdatePages
  jmp e2444_IncID
e2444_UnisonPageCheck:
  cmp word ptr [TOS.exe+0x1831908],0x1
  je e2444_IncID
  movzx ecx,word ptr [TOS.exe+0x183191E]
  mov ebx,0x1
  shl ebx,cl
  jmp e2444_SkipResetAllPages
e2444_ArtesPageCheck:
  mov ecx,[TOS.exe+0x713ABE]
  cmp byte ptr [PageCache],cl
  jne e2444_ResetAllPages
  mov byte ptr [PageCache],cl
  cmp word ptr [TOS.exe+0x713AB0],0x2
  ja e2444_IncID
  jne e2444_IncID
  cmp byte ptr [ShortcutState],0x1
  je e2444_IncID
  movzx ebx,byte ptr [TOS.exe+0x713ABE]
  call e2444_Func_GetPartySlot
e2444_MergePageCheck:
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  cmp word ptr [edx+0x114+0x7E],0x0
  pop edx
  je e2444_SkipResetAllPages
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  test word ptr [edx+0x114+0x7E],bx
  pop edx
  je e2444_ResetAllPages
e2444_SkipResetAllPages:
  cmp byte ptr [StoredControls+eax+0x5],0x1
  jne e2444_IncID
  xor word ptr [PageSwitch],bx
  mov ecx,0x1F
  call TOS.exe+0x12E5B0
  call e2444_Func_UpdatePages
  jmp e2444_IncID
e2444_Func_GetInputs:
  mov word ptr [MainControls],cx
  mov eax,ebx
  imul eax,eax,0x10
e2444_GetInputsLoop:
  movzx ecx,byte ptr [LoopCounter]
  mov edx,0x1
  shl dx,cl
  add ecx,eax
  test word ptr [MainControls],dx
  je e2444_ReleasedButton
  cmp byte ptr [StoredControls+ecx],0xFF
  jae e2444_GetInputsEnd
  inc byte ptr [StoredControls+ecx]
  jmp e2444_GetInputsEnd
e2444_ReleasedButton:
  mov byte ptr [StoredControls+ecx],0x0
e2444_GetInputsEnd:
  inc byte ptr [LoopCounter]
  cmp byte ptr [LoopCounter],0x10
  jb e2444_GetInputsLoop
  mov byte ptr [LoopCounter],0x0
  ret
e2444_Func_ResetPage:
  not ebx
  and word ptr [PageSwitch],bx
  ret
e2444_Func_ResetAllPages:
  mov word ptr [PageSwitch],0x0
  call e2444_Func_UpdatePages
  ret
e2444_Func_UpdatePages:
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea esi,[edx+0x114]
  pop edx
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea edi,[edx+0x440]
  pop edx
e2444_UpdatePagesLoopMain:
  movzx ecx,byte ptr [LoopCounter]
  movzx ebx,word ptr [PageSwitch]
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  movzx eax,word ptr [edx+0x114+0x7E]
  pop edx
  shr ax,cl
  shr bx,cl
  and ax,0x1
  and bx,0x1
  cmp bx,ax
  je e2444_SkipUpdatePage
e2444_UpdatePagesLoopSub:
  mov ecx,[esi]
  xchg ecx,[edi]
  mov [esi],ecx
  add esi,0x4
  add edi,0x4
  inc byte ptr [LoopCounter+0x1]
  cmp byte ptr [LoopCounter+0x1],0x4
  jb e2444_UpdatePagesLoopSub
  mov byte ptr [LoopCounter+0x1],0x0
  sub esi,0x2
  sub edi,0x2
  movzx ecx,word ptr [esi]
  xchg cx,word ptr [edi]
  mov word ptr [esi],cx
  sub esi,0xE
  sub edi,0xE
e2444_SkipUpdatePage:
  add esi,0xE
  add edi,0x118
  inc byte ptr [LoopCounter]
  cmp byte ptr [LoopCounter],0x9
  jb e2444_UpdatePagesLoopMain
  mov byte ptr [LoopCounter],0x0
  movzx ebx,word ptr [PageSwitch]
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  mov word ptr [edx+0x114+0x7E],bx
  pop edx
  ret
e2444_Func_GetPartySlot:
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  movzx ecx,byte ptr [edx+0xf4d+ebx]
  pop edx
  sub ecx,0x1
  mov ebx,0x1
  shl ebx,cl
  ret
e2444_Func_GetController:
  mov eax,0x10
  mul byte ptr [ControlID]
  ret
e2444_IncID:
e2444_Code_ButtonInputs:
  cmp byte ptr [BattleState],0x0
  je e2444_UnlockAll
  movzx ecx,byte ptr [ControlID]
  mov eax,ecx
  imul eax,0x10
  test byte ptr [BattleMenu],0x1
  jne e2444_UnlockChecks
  push eax
  movzx eax,byte ptr [LockA+ecx]
  add al,byte ptr [LockB+ecx]
  cmp al,0x0
  pop eax
  jne e2444_LockChecks
  cmp byte ptr [CurrentState+ecx],0x4
  je e2444_StateCheck
  cmp byte ptr [CurrentState+ecx],0x5
  je e2444_StateCheck
  cmp byte ptr [CurrentState+ecx],0x2
  ja e2444_DebugTest
e2444_StateCheck:
  cmp byte ptr [StoredControls+eax+0xA],0x0
  je e2444_UnlockChecks
  mov byte ptr [LockRS+ecx],0x1
  jmp e2444_LockChecks
e2444_LockChecks:
  cmp byte ptr [StoredControls+eax+0xC],0x0
  je e2444_UnlockA
  mov byte ptr [LockA+ecx],0x1
  jmp e2444_LockCheckB
e2444_UnlockA:
  mov byte ptr [LockA+ecx],0x0
e2444_LockCheckB:
  cmp byte ptr [StoredControls+eax+0xD],0x0
  je e2444_UnlockB
  mov byte ptr [LockB+ecx],0x1
  jmp e2444_LockCheckX
e2444_UnlockB:
  mov byte ptr [LockB+ecx],0x0
e2444_LockCheckX:
  cmp byte ptr [StoredControls+eax+0xE],0x0
  je e2444_UnlockX
  mov byte ptr [LockX+ecx],0x1
  jmp e2444_UpdateLocks
e2444_UnlockX:
  mov byte ptr [LockX+ecx],0x0
  jmp e2444_UpdateLocks
e2444_UnlockChecks:
  test byte ptr [LockA+ecx],0x1
  je e2444_UnlockCheckB
  cmp byte ptr [StoredControls+eax+0xC],0x0
  jne e2444_UnlockCheckB
  mov byte ptr [LockA+ecx],0x0
e2444_UnlockCheckB:
  test byte ptr [LockB+ecx],0x1
  je e2444_UnlockCheckX
  cmp byte ptr [StoredControls+eax+0xD],0x0
  jne e2444_UnlockCheckX
  mov byte ptr [LockB+ecx],0x0
e2444_UnlockCheckX:
  mov byte ptr [LockX+ecx],0x0
e2444_UnlockCheckRS:
  mov byte ptr [LockRS+ecx],0x0
e2444_UpdateLocks:
  test byte ptr [LockA+ecx],0x1
  je e2444_UpdateLockB
  and word ptr [MainControls],0xEFFF
e2444_UpdateLockB:
  test byte ptr [LockB+ecx],0x1
  je e2444_UpdateLockX
  and word ptr [MainControls],0xDFFF
e2444_UpdateLockX:
  test byte ptr [LockX+ecx],0x1
  je e2444_DebugTest
  and word ptr [MainControls],0xBFFF
  jmp e2444_DebugTest
e2444_UnlockAll:
  mov DWORD PTR [LockA],0x0
  mov DWORD PTR [LockB],0x0
  mov DWORD PTR [LockX],0x0
  mov DWORD PTR [LockRS],0x0
e2444_DebugTest:
  pop edi
  pop esi
  pop eax
  movzx ecx,word ptr [MainControls]
  mov [esi+0x10],ecx
  mov edx,ecx
  jmp e2444_Ret_ButtonInputs
input_passthrough:
  pop eax
  popfd
  mov [esi+0x10], ecx
  mov edx, ecx
  jmp e2444_Ret_ButtonInputs

// Inputs [NEW]
TOS.exe+0x211a73:
  jmp e2444_Mem_ButtonInputs
e2444_Ret_ButtonInputs:

// ArtesSphere / CT 2679: Arte Page Indicator

// Arte Page Indicator
mem_payload_e2679_Mem_ArtePageIndicator:
e2679_Mem_ArtePageIndicator:

// Arte Page Indicator
mem_payload_PageString:
PageString:

// Arte Page Indicator
mem_payload_e2679_Mem_ArtePageIndicator:
  call TOS.exe+0x132250
  movzx edx,byte ptr [TOS.exe+0x713ABE]
  cmp dl,0x4
  jnl e2679_Ret_ArtePageIndicator
  mov ecx,[TOS.exe+0x6D3F68]
  cmp byte ptr [edx+ecx+0xF55],0x2
  jnl e2679_Ret_ArtePageIndicator
  mov ecx,[ebp+0x10]
  xor edx,edx
  cmp word ptr [PageSwitch],0x0
  jne e2679_PageSub
  lea eax,[PageString]
  mov DWORD PTR [esp+0x4],0x77
  add edi,#322
  mov [esp],edi
  jmp e2679_Code_ArtePageIndicator
e2679_PageSub:
  lea eax,[PageString+0x5]
  mov ecx,[ebp+0x10]
  xor edx,edx
  mov DWORD PTR [esp+0x4],0x77
  add edi,#332
  mov [esp],edi
e2679_Code_ArtePageIndicator:
  lea edi,[ebx+0xC]
  call TOS.exe+0x132250
  jmp e2679_Ret_ArtePageIndicator

// Arte Page Indicator
mem_payload_PageString:
  db 0x4D,0x61,0x69,0x6E,0x00
  db 0x53,0x75,0x62,0x00,0x00

// Arte Page Indicator
TOS.exe+0x120b83:
  jmp e2679_Mem_ArtePageIndicator
e2679_Ret_ArtePageIndicator:

// ArtesSphere / CT 2687: Unison Arte Page Indicator

// Unison Arte Page Indicator
mem_payload_e2687_Mem_UnisonPageIndicator:
e2687_Mem_UnisonPageIndicator:

// Unison Arte Page Indicator
mem_payload_e2687_Mem_UnisonPageIndicator:
  call TOS.exe+0x132250
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  movzx ecx, BYTE PTR [edx+0xf4d+edi]
  pop edx
  dec ecx
  mov eax,0x1
  shl eax,cl
  test word ptr [PageSwitch],ax
  lea eax,[ebx+0x2D]
  jne e2687_PageSub
  add eax,#320
  mov [esp],eax
  lea eax,[PageString]
  jmp e2687_Code_UnisonPageIndicator
e2687_PageSub:
  add eax,#330
  mov [esp],eax
  lea eax,[PageString+0x5]
e2687_Code_UnisonPageIndicator:
  call TOS.exe+0x132250
  mov eax,[esp+0x40]
  jmp e2687_Ret_UnisonPageIndicator

// Unison Arte Page Indicator
TOS.exe+0x1270f0:
  jmp e2687_Mem_UnisonPageIndicator
e2687_Ret_UnisonPageIndicator:

// ArtesSphere / CT 2473: Arte Sphere Set Buffer (1st Attack)

// Arte Sphere Set Buffer (1st Attack)
mem_payload_e2473_Mem_BattleArteBuffer:
e2473_Mem_BattleArteBuffer:

// Arte Sphere Set Buffer (1st Attack)
mem_payload_e2473_Mem_BattleArteBuffer:
// Refresh the layer for the configured arte button OR either shortcut.
// Right-stick Y becomes 0x400/0x800 after input capture. Testing only the
// face button leaves shortcuts using the previous attack's CharBuffer bit.
  mov esi,[eax+0x9070]
  or esi,0xC00
  and esi,edx
  je TOS.exe+0x75D4F
  push ecx
  movzx ecx,byte ptr [edi+0x1321]
  and ecx,0x3
  imul ecx,0x10
  push eax
  cmp byte ptr [StoredControls+ecx+0x8],0x0
  jne e2473_ArteSphereCheck
  call e2473_QuickTest
  not eax
  and ecx,eax
  mov word ptr [CharBuffer],cx
  jmp e2473_Code_BattleArteBuffer
e2473_ArteSphereCheck:
  call e2473_QuickTest
  or ecx,eax
  mov word ptr [CharBuffer],cx
  jmp e2473_Code_BattleArteBuffer
e2473_QuickTest:
  movzx ecx,byte ptr [edi+0x1322]
  dec ecx
  mov eax,0x1
  shl eax,cl
  movzx ecx,word ptr [CharBuffer]
  ret
e2473_Code_BattleArteBuffer:
  pop eax
  pop ecx
  mov esi,[eax+0x00009070]
  jmp e2473_Ret_BattleArteBuffer

// Arte Sphere Set Buffer (1st Attack)
TOS.exe+0x75d2c:
  jmp e2473_Mem_BattleArteBuffer
  nop
e2473_Ret_BattleArteBuffer:

// ArtesSphere / CT 2476: Arte Sphere Set Buffer (Combo)

// Arte Sphere Set Buffer (Combo)
mem_payload_e2476_Mem_BattleArteBufferCombo:
e2476_Mem_BattleArteBufferCombo:

// Arte Sphere Set Buffer (Combo)
mem_payload_e2476_Mem_BattleArteBufferCombo:
  push eax
  mov eax,[eax+0x9070]
  or eax,0xC00
  and eax,ecx
  pop eax
  je TOS.exe+0x346E9
  push ecx
  movzx ecx,byte ptr [esi+0x1321]
  and ecx,0x3
  imul ecx,0x10
  push eax
  cmp byte ptr [StoredControls+ecx+0x8],0x0
  jne e2476_ArteSphereCheck
  call e2476_QuickTest
  not eax
  and ecx,eax
  mov word ptr [CharBuffer],cx
  jmp e2476_Code_BattleArteBufferCombo
e2476_ArteSphereCheck:
  call e2476_QuickTest
  or ecx,eax
  mov word ptr [CharBuffer],cx
  jmp e2476_Code_BattleArteBufferCombo
e2476_QuickTest:
  movzx ecx,byte ptr [esi+0x1322]
  dec ecx
  mov eax,0x1
  shl eax,cl
  movzx ecx,word ptr [CharBuffer]
  ret
e2476_Code_BattleArteBufferCombo:
  pop eax
  pop ecx
  test [eax+0x00009070],ecx
  jmp e2476_Ret_BattleArteBufferCombo

// Arte Sphere Set Buffer (Combo)
TOS.exe+0x346a5:
  jmp e2476_Mem_BattleArteBufferCombo
  nop
e2476_Ret_BattleArteBufferCombo:

// ArtesSphere / CT 2475: Arte Sphere Set Buffer (Air)

// Arte Sphere Set Buffer (Air)
mem_payload_e2475_Mem_BattleArteBufferAir:
e2475_Mem_BattleArteBufferAir:

// Arte Sphere Set Buffer (Air)
mem_payload_e2475_Mem_BattleArteBufferAir:
  mov eax,[ecx+0x9070]
  or eax,0xC00
  test [edx],eax
  je TOS.exe+0x75A7B
  push ecx
  movzx ecx,byte ptr [edi+0x1321]
  and ecx,0x3
  imul ecx,0x10
  push eax
  cmp byte ptr [StoredControls+ecx+0x8],0x0
  jne e2475_ArteSphereCheck
  call e2475_QuickTest
  not eax
  and ecx,eax
  mov word ptr [CharBuffer],cx
  jmp e2475_Code_BattleArteBufferAir
e2475_ArteSphereCheck:
  call e2475_QuickTest
  or ecx,eax
  mov word ptr [CharBuffer],cx
  jmp e2475_Code_BattleArteBufferAir
e2475_QuickTest:
  movzx ecx,byte ptr [edi+0x1322]
  dec ecx
  mov eax,0x1
  shl eax,cl
  movzx ecx,word ptr [CharBuffer]
  ret
e2475_Code_BattleArteBufferAir:
  pop eax
  pop ecx
  mov eax,[ecx+0x9070]
  jmp e2475_Ret_BattleArteBufferAir

// Arte Sphere Set Buffer (Air)
TOS.exe+0x75a1f:
  jmp e2475_Mem_BattleArteBufferAir
  nop
e2475_Ret_BattleArteBufferAir:

// ArtesSphere / CT 2477: Arte Sphere Check (1st Attack)

// Arte Sphere Check (1st Attack)
mem_payload_e2477_Mem_BattleArte:
e2477_Mem_BattleArte:

// Arte Sphere Check (1st Attack)
mem_payload_e2477_Mem_BattleArte:
  push ebx
  push ecx
  movzx ecx,byte ptr [edi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2477_ArteSphereCheck
  pop ecx
  pop ebx
  cmp word ptr [ebx+ecx*0x2+0xD8],0x0
  jmp e2477_Ret_BattleArte
e2477_ArteSphereCheck:
  movzx ebx,byte ptr [edi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  cmp word ptr [ebx+ecx*0x2],0x0
  pop ebx
  jmp e2477_Ret_BattleArte

// Arte Sphere Check (1st Attack)
TOS.exe+0x75d3f:
  jmp e2477_Mem_BattleArte
  nop #4
e2477_Ret_BattleArte:

// ArtesSphere / CT 2478: Arte Sphere Use (1st Attack)

// Arte Sphere Use (1st Attack)
mem_payload_e2478_Mem_BattleArteSelect:
e2478_Mem_BattleArteSelect:

// Arte Sphere Use (1st Attack)
mem_payload_e2478_Mem_BattleArteSelect:
  push ebx
  push ecx
  movzx ecx,byte ptr [edi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2478_ArteSphereCheck
  pop ecx
  pop ebx
  movzx eax,word ptr [edx+ecx*0x2+0xD8]
  jmp e2478_Ret_BattleArteSelect
e2478_ArteSphereCheck:
  movzx ebx,byte ptr [edi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  movzx eax,word ptr [ebx+ecx*0x2]
  pop ebx
  jmp e2478_Ret_BattleArteSelect

// Arte Sphere Use (1st Attack)
TOS.exe+0x76129:
  jmp e2478_Mem_BattleArteSelect
  nop #3
e2478_Ret_BattleArteSelect:

// ArtesSphere / CT 2479: Arte Sphere Check (Combo)

// Arte Sphere Check (Combo)
mem_payload_e2479_Mem_BattleArteCombo:
e2479_Mem_BattleArteCombo:

// Arte Sphere Check (Combo)
mem_payload_e2479_Mem_BattleArteCombo:
  push ebx
  push ecx
  movzx ecx,byte ptr [esi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2479_ArteSphereCheck
  pop ecx
  pop ebx
  cmp word ptr [edx+ecx*0x2+0xD8],0x0
  jmp e2479_Ret_BattleArteCombo
e2479_ArteSphereCheck:
  movzx ebx,byte ptr [esi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  cmp word ptr [ebx+ecx*0x2],0x0
// Balance the saved EBX on the Sub branch as well as the Main branch.
  pop ebx
  jmp e2479_Ret_BattleArteCombo

// Arte Sphere Check (Combo)
TOS.exe+0x346be:
  jmp e2479_Mem_BattleArteCombo
  nop #4
e2479_Ret_BattleArteCombo:

// ArtesSphere / CT 2480: Arte Sphere Use (Combo)

// Arte Sphere Use (Combo)
mem_payload_e2480_Mem_BattleArteSelectCombo:
e2480_Mem_BattleArteSelectCombo:

// Arte Sphere Use (Combo)
mem_payload_e2480_Mem_BattleArteSelectCombo:
  push eax
  push ecx
  movzx ecx,byte ptr [edi+0x1322]
  dec ecx
  mov eax,0x1
  shl eax,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,ax
  jne e2480_ArteSphereCheck
  pop ecx
  pop eax
  movzx ebx,word ptr [eax+edx*0x2+0xD8]
  jmp e2480_Ret_BattleArteSelectCombo
e2480_ArteSphereCheck:
  movzx eax,byte ptr [edi+0x1322]
  dec eax
  imul eax,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add eax,ecx
  pop ecx
  movzx ebx,word ptr [eax+edx*0x2]
  pop eax
  jmp e2480_Ret_BattleArteSelectCombo

// Arte Sphere Use (Combo)
TOS.exe+0x34811:
  jmp e2480_Mem_BattleArteSelectCombo
  nop #3
e2480_Ret_BattleArteSelectCombo:

// ArtesSphere / CT 2481: Arte Sphere Use (Air Attack)

// Arte Sphere Use (Air Attack)
mem_payload_e2481_Mem_BattleArteSelectAir:
e2481_Mem_BattleArteSelectAir:

// Arte Sphere Use (Air Attack)
mem_payload_e2481_Mem_BattleArteSelectAir:
  push ebx
  push ecx
  movzx ecx,byte ptr [edi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2481_ArteSphereCheck
  pop ecx
  pop ebx
  movzx eax,word ptr [edx+ecx*0x2+0xD8]
  jmp e2481_Ret_BattleArteSelectAir
e2481_ArteSphereCheck:
  movzx ebx,byte ptr [edi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  movzx eax,word ptr [ebx+ecx*0x2]
  pop ebx
  jmp e2481_Ret_BattleArteSelectAir

// Arte Sphere Use (Air Attack)
TOS.exe+0x75a5f:
  jmp e2481_Mem_BattleArteSelectAir
  nop #3
e2481_Ret_BattleArteSelectAir:

// ArtesSphere / CT 2456: Arte Sphere Use Char/Shortcut 1 (Command)

// Arte Sphere Use Char/Shortcut 1 (Command)
mem_payload_e2456_Mem_BattleArteCharCommand1:
e2456_Mem_BattleArteCharCommand1:

// Arte Sphere Use Char/Shortcut 1 (Command)
mem_payload_e2456_Mem_BattleArteCharCommand1:
// The caller supplies the owner in EAX; ESI is not assigned yet.
  movzx ecx,byte ptr [eax+0x1321]
  and ecx,0x3
  imul ecx,0x10
  cmp byte ptr [StoredControls+ecx+0x8],0x0
  jne e2456_ArteSphereCheck
  call e2456_QuickTest
  not ebx
  and ecx,ebx
  mov word ptr [CharBuffer],cx
  movzx ecx,byte ptr [edi+0xE4]
  jmp e2456_Ret_BattleArteCharCommand1
e2456_ArteSphereCheck:
  call e2456_QuickTest
  mov edi,ebx
  or ecx,edi
  mov word ptr [CharBuffer],cx
  movzx edi,byte ptr [eax+0x1322]
  dec edi
  imul edi,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add edi,ecx
  movzx ecx,byte ptr [edi+0xC]
  jmp e2456_Ret_BattleArteCharCommand1
e2456_QuickTest:
  movzx ecx,byte ptr [eax+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  ret
e2456_Mem_BattleArteShortcutCommand1:
// EAX now contains the selected target. The owner's stable argument is EBP+8.
  push edx
  mov edx,[ebp+0x8]
  movzx ecx,byte ptr [edx+0x1322]
  pop edx
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2456_ArteSphereCheck2
  movzx edi,word ptr [edi+0xE0]
  jmp e2456_Ret_BattleArteShortcutCommand1
e2456_ArteSphereCheck2:
  movzx edi,word ptr [edi+0x8]
  jmp e2456_Ret_BattleArteShortcutCommand1

// Arte Sphere Use Char/Shortcut 1 (Command)
TOS.exe+0x751d9:
  jmp e2456_Mem_BattleArteCharCommand1
  nop #2
e2456_Ret_BattleArteCharCommand1:

// Arte Sphere Use Char/Shortcut 1 (Command)
TOS.exe+0x751e6:
  jmp e2456_Mem_BattleArteShortcutCommand1
  nop #2
e2456_Ret_BattleArteShortcutCommand1:

// ArtesSphere / CT 2549: Arte Sphere Use Char/Shortcut 2 (Command)

// Arte Sphere Use Char/Shortcut 2 (Command)
mem_payload_e2549_Mem_BattleArteCharCommand2:
e2549_Mem_BattleArteCharCommand2:

// Arte Sphere Use Char/Shortcut 2 (Command)
mem_payload_e2549_Mem_BattleArteCharCommand2:
  movzx ecx,byte ptr [edx+0x1321]
  and ecx,0x3
  imul ecx,0x10
  cmp byte ptr [StoredControls+ecx+0x8],0x0
  jne e2549_ArteSphereCheck
  call e2549_QuickTest
  not ebx
  and ecx,ebx
  mov word ptr [CharBuffer],cx
  movzx eax,byte ptr [edi+0xE5]
  jmp e2549_Ret_BattleArteCharCommand2
e2549_ArteSphereCheck:
  call e2549_QuickTest
  mov edi,ebx
  or ecx,edi
  mov word ptr [CharBuffer],cx
  movzx edi,byte ptr [edx+0x1322]
  dec edi
  imul edi,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add edi,ecx
  movzx eax,byte ptr [edi+0xD]
  jmp e2549_Ret_BattleArteCharCommand2
e2549_QuickTest:
  movzx ecx,byte ptr [edx+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  ret
e2549_Mem_BattleArteShortcutCommand2:
  push ecx
  mov edx,[ebp+0x8]
  movzx ecx,byte ptr [edx+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2549_ArteSphereCheck2
  pop ecx
  movzx edi,word ptr [edi+0xE2]
  jmp e2549_Ret_BattleArteShortcutCommand2
e2549_ArteSphereCheck2:
  pop ecx
  movzx edi,word ptr [edi+0xA]
  jmp e2549_Ret_BattleArteShortcutCommand2

// Arte Sphere Use Char/Shortcut 2 (Command)
TOS.exe+0x75214:
  jmp e2549_Mem_BattleArteCharCommand2
  nop #2
e2549_Ret_BattleArteCharCommand2:

// Arte Sphere Use Char/Shortcut 2 (Command)
TOS.exe+0x75221:
  jmp e2549_Mem_BattleArteShortcutCommand2
  nop #2
e2549_Ret_BattleArteShortcutCommand2:

// ArtesSphere / CT 2452: Arte Sphere Check Char 1 A (1st Attack)

// Arte Sphere Check Char 1 A (1st Attack)
mem_payload_e2452_Mem_BattleArteChar1_A:
e2452_Mem_BattleArteChar1_A:

// Arte Sphere Check Char 1 A (1st Attack)
mem_payload_e2452_Mem_BattleArteChar1_A:
  push eax
  push ecx
  movzx ecx, WORD PTR [edi+0x1322]
  dec ecx
  mov eax,0x1
  shl eax,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,ax
  jne e2452_ArteSphereCheck
  pop ecx
  pop eax
  cmp [ebx+0xE4],cl
  jmp e2452_Ret_BattleArteChar1_A
e2452_ArteSphereCheck:
  movzx eax,byte ptr [edi+0x1322]
  dec eax
  imul eax,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add eax,ecx
  pop ecx
  cmp [eax+0xC],cl
  pop eax
  jmp e2452_Ret_BattleArteChar1_A

// Arte Sphere Check Char 1 A (1st Attack)
TOS.exe+0x75d62:
  jmp e2452_Mem_BattleArteChar1_A
  nop
e2452_Ret_BattleArteChar1_A:

// ArtesSphere / CT 2553: Arte Sphere Check Char 2 A (1st Attack)

// Arte Sphere Check Char 2 A (1st Attack)
mem_payload_e2553_Mem_BattleArteChar2_A:
e2553_Mem_BattleArteChar2_A:

// Arte Sphere Check Char 2 A (1st Attack)
mem_payload_e2553_Mem_BattleArteChar2_A:
  push eax
  push ecx
  movzx ecx, WORD PTR [edi+0x1322]
  dec ecx
  mov eax,0x1
  shl eax,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,ax
  jne e2553_ArteSphereCheck
  pop ecx
  pop eax
  cmp [ebx+0xE5],cl
  jmp e2553_Ret_BattleArteChar2_A
e2553_ArteSphereCheck:
  movzx eax,byte ptr [edi+0x1322]
  dec eax
  imul eax,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add eax,ecx
  pop ecx
  cmp [eax+0xD],cl
  pop eax
  jmp e2553_Ret_BattleArteChar2_A

// Arte Sphere Check Char 2 A (1st Attack)
TOS.exe+0x75d82:
  jmp e2553_Mem_BattleArteChar2_A
  nop
e2553_Ret_BattleArteChar2_A:

// ArtesSphere / CT 2554: Arte Sphere Use Shortcut 1 B (1st Attack)

// Arte Sphere Use Shortcut 1 B (1st Attack)
mem_payload_e2554_Mem_BattleArteSelectShortcut1_B:
e2554_Mem_BattleArteSelectShortcut1_B:

// Arte Sphere Use Shortcut 1 B (1st Attack)
mem_payload_e2554_Mem_BattleArteSelectShortcut1_B:
  push ebx
  push ecx
  movzx ecx, WORD PTR [edi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2554_ArteSphereCheck
  pop ecx
  pop ebx
  movzx esi,word ptr [eax+0xE0]
  jmp e2554_Ret_BattleArteSelectShortcut1_B
e2554_ArteSphereCheck:
  movzx ebx,byte ptr [edi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  movzx esi,word ptr [ebx+0x8]
  pop ebx
  jmp e2554_Ret_BattleArteSelectShortcut1_B
e2554_Mem_BattleArteChar1_B:
  push ebx
  push ecx
  movzx ecx, WORD PTR [edi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2554_ArteSphereCheck2
  pop ecx
  pop ebx
  cmp [eax+0xE4],cl
  jmp e2554_Ret_BattleArteChar1_B
e2554_ArteSphereCheck2:
  movzx ebx,byte ptr [edi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  cmp [ebx+0xC],cl
  pop ebx
  jmp e2554_Ret_BattleArteChar1_B

// Arte Sphere Use Shortcut 1 B (1st Attack)
TOS.exe+0x7614e:
  jmp e2554_Mem_BattleArteSelectShortcut1_B
  nop #2
e2554_Ret_BattleArteSelectShortcut1_B:

// Arte Sphere Use Shortcut 1 B (1st Attack)
TOS.exe+0x76163:
  jmp e2554_Mem_BattleArteChar1_B
  nop
e2554_Ret_BattleArteChar1_B:

// ArtesSphere / CT 2552: Arte Sphere Use Shortcut 2 B (1st Attack)

// Arte Sphere Use Shortcut 2 B (1st Attack)
mem_payload_e2552_Mem_BattleArteSelectShortcut2_B:
e2552_Mem_BattleArteSelectShortcut2_B:

// Arte Sphere Use Shortcut 2 B (1st Attack)
mem_payload_e2552_Mem_BattleArteSelectShortcut2_B:
  push ebx
  push ecx
  movzx ecx, WORD PTR [edi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2552_ArteSphereCheck
  pop ecx
  pop ebx
  movzx esi,word ptr [eax+0xE2]
  jmp e2552_Ret_BattleArteSelectShortcut2_B
e2552_ArteSphereCheck:
  movzx ebx,byte ptr [edi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  movzx esi,word ptr [ebx+0xA]
  pop ebx
  jmp e2552_Ret_BattleArteSelectShortcut2_B
e2552_Mem_BattleArteChar2_B:
  push ebx
  push ecx
  movzx ecx, WORD PTR [edi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2552_ArteSphereCheck2
  pop ecx
  pop ebx
  cmp [eax+0xE5],cl
  jmp e2552_Ret_BattleArteChar2_B
e2552_ArteSphereCheck2:
  movzx ebx,byte ptr [edi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  cmp [ebx+0xD],cl
  pop ebx
  jmp e2552_Ret_BattleArteChar2_B

// Arte Sphere Use Shortcut 2 B (1st Attack)
TOS.exe+0x7618f:
  jmp e2552_Mem_BattleArteSelectShortcut2_B
  nop #2
e2552_Ret_BattleArteSelectShortcut2_B:

// Arte Sphere Use Shortcut 2 B (1st Attack)
TOS.exe+0x761a4:
  jmp e2552_Mem_BattleArteChar2_B
  nop
e2552_Ret_BattleArteChar2_B:

// ArtesSphere / CT 2459: Arte Sphere Check Char/Shortcut (Combo)

// Arte Sphere Check Char/Shortcut (Combo)
mem_payload_e2459_Mem_BattleArteChar1Combo:
e2459_Mem_BattleArteChar1Combo:

// Arte Sphere Check Char/Shortcut (Combo)
mem_payload_e2459_Mem_BattleArteChar1Combo:
  push eax
  push ecx
  movzx ecx,byte ptr [esi+0x1322]
  dec ecx
  mov eax,0x1
  shl eax,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,ax
  jne e2459_ArteSphereCheck
  pop ecx
  pop eax
  cmp [eax+0xE4],bl
  jmp e2459_Ret_BattleArteChar1Combo
e2459_ArteSphereCheck:
  movzx eax,byte ptr [esi+0x1322]
  dec eax
  imul eax,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add eax,ecx
  pop ecx
  cmp [eax+0xC],bl
  pop eax
  jmp e2459_Ret_BattleArteChar1Combo
e2459_Mem_BattleArteShortcut1Combo:
  push ebx
  push ecx
  movzx ecx,byte ptr [esi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2459_ArteSphereCheck2
  pop ecx
  pop ebx
  jne e2459_ArteSphereCheck2
  cmp word ptr [eax+0xE0],0x0
  jmp e2459_Ret_BattleArteShortcut1Combo
e2459_ArteSphereCheck2:
  movzx ebx,byte ptr [esi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  cmp word ptr [ebx+0x8],0x0
  pop ebx
  jmp e2459_Ret_BattleArteShortcut1Combo
e2459_Mem_BattleArteChar2Combo:
  push eax
  push ecx
  movzx ecx,byte ptr [esi+0x1322]
  dec ecx
  mov eax,0x1
  shl eax,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,ax
  jne e2459_ArteSphereCheck3
  pop ecx
  pop eax
  cmp [eax+0xE5],bl
  jmp e2459_Ret_BattleArteChar2Combo
e2459_ArteSphereCheck3:
  movzx eax,byte ptr [esi+0x1322]
  dec eax
  imul eax,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add eax,ecx
  pop ecx
  cmp [eax+0xD],bl
  pop eax
  jmp e2459_Ret_BattleArteChar2Combo
e2459_Mem_BattleArteShortcut2Combo:
  push ebx
  push ecx
  movzx ecx,byte ptr [esi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2459_ArteSphereCheck4
  pop ecx
  pop ebx
  cmp word ptr [eax+0xE2],0x0
  jmp e2459_Ret_BattleArteShortcut2Combo
e2459_ArteSphereCheck4:
  movzx ebx,byte ptr [esi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  cmp word ptr [ebx+0xA],0x0
  pop ebx
  jmp e2459_Ret_BattleArteShortcut2Combo

// Arte Sphere Check Char/Shortcut (Combo)
TOS.exe+0x346fc:
  jmp e2459_Mem_BattleArteChar1Combo
  nop
e2459_Ret_BattleArteChar1Combo:

// Arte Sphere Check Char/Shortcut (Combo)
TOS.exe+0x3470c:
  jmp e2459_Mem_BattleArteShortcut1Combo
  nop #3
e2459_Ret_BattleArteShortcut1Combo:

// Arte Sphere Check Char/Shortcut (Combo)
TOS.exe+0x3471d:
  jmp e2459_Mem_BattleArteChar2Combo
  nop
e2459_Ret_BattleArteChar2Combo:

// Arte Sphere Check Char/Shortcut (Combo)
TOS.exe+0x3472d:
  jmp e2459_Mem_BattleArteShortcut2Combo
  nop #3
e2459_Ret_BattleArteShortcut2Combo:

// ArtesSphere / CT 2474: Arte Sphere Check Char/Shortcut 1 (Air)

// Arte Sphere Check Char/Shortcut 1 (Air)
mem_payload_e2474_Mem_BattleArteChar1Air:
e2474_Mem_BattleArteChar1Air:

// Arte Sphere Check Char/Shortcut 1 (Air)
mem_payload_e2474_Mem_BattleArteChar1Air:
  push ebx
  push ecx
  movzx ecx,byte ptr [edi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2474_ArteSphereCheck
  pop ecx
  pop ebx
  cmp [eax+0xE4],dl
  jmp e2474_Ret_BattleArteChar1Air
e2474_ArteSphereCheck:
  movzx ebx,byte ptr [edi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  cmp [ebx+0xC],dl
  pop ebx
  jmp e2474_Ret_BattleArteChar1Air
e2474_Mem_BattleArteShortcut1Air:
  push ebx
  push ecx
  movzx ecx,byte ptr [edi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2474_ArteSphereCheck2
  pop ecx
  pop ebx
  movzx eax,word ptr [eax+0xE0]
  jmp e2474_Ret_BattleArteShortcut1Air
e2474_ArteSphereCheck2:
  movzx ebx,byte ptr [edi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  movzx eax,word ptr [ebx+0x8]
  pop ebx
  jmp e2474_Ret_BattleArteShortcut1Air

// Arte Sphere Check Char/Shortcut 1 (Air)
TOS.exe+0x75a9f:
  jmp e2474_Mem_BattleArteChar1Air
  nop
e2474_Ret_BattleArteChar1Air:

// Arte Sphere Check Char/Shortcut 1 (Air)
TOS.exe+0x75aaf:
  jmp e2474_Mem_BattleArteShortcut1Air
  nop #2
e2474_Ret_BattleArteShortcut1Air:

// ArtesSphere / CT 2555: Arte Sphere Check Char/Shortcut 2 (Air)

// Arte Sphere Check Char/Shortcut 2 (Air)
mem_payload_e2555_Mem_BattleArteChar2Air:
e2555_Mem_BattleArteChar2Air:

// Arte Sphere Check Char/Shortcut 2 (Air)
mem_payload_e2555_Mem_BattleArteChar2Air:
  push ebx
  push ecx
  movzx ecx,byte ptr [edi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2555_ArteSphereCheck
  pop ecx
  pop ebx
  cmp [eax+0xE5],cl
  jmp e2555_Ret_BattleArteChar2Air
e2555_ArteSphereCheck:
  movzx ebx,byte ptr [edi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  cmp [ebx+0xD],cl
  pop ebx
  jmp e2555_Ret_BattleArteChar2Air
e2555_Mem_BattleArteShortcut2Air:
  push ebx
  push ecx
  movzx ecx,byte ptr [edi+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  test cx,bx
  jne e2555_ArteSphereCheck2
  pop ecx
  pop ebx
  movzx eax,word ptr [eax+0xE2]
  jmp e2555_Ret_BattleArteShortcut2Air
e2555_ArteSphereCheck2:
  movzx ebx,byte ptr [edi+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  movzx eax,word ptr [ebx+0xA]
  pop ebx
  jmp e2555_Ret_BattleArteShortcut2Air

// Arte Sphere Check Char/Shortcut 2 (Air)
TOS.exe+0x75ad5:
  jmp e2555_Mem_BattleArteChar2Air
  nop
e2555_Ret_BattleArteChar2Air:

// Arte Sphere Check Char/Shortcut 2 (Air)
TOS.exe+0x75af4:
  jmp e2555_Mem_BattleArteShortcut2Air
  nop #2
e2555_Ret_BattleArteShortcut2Air:

// ArtesSphere / CT 2569: Arte Sphere Use Unison

// Arte Sphere Use Unison
mem_payload_e2569_Mem_BattleArteUnison:
e2569_Mem_BattleArteUnison:

// Arte Sphere Use Unison
mem_payload_e2569_Mem_BattleArteUnison:
  push ebx
  push ecx
  movzx ecx,byte ptr [UnisonID]
  and ecx,0x3
  imul ecx,0x10
  cmp byte ptr [StoredControls+ecx+0x8],0x0
  jne e2569_ArteSphereCheck
  movzx ecx,byte ptr [ebx+0x1322]
  dec ecx
  mov ebx,0x1
  shl ebx,cl
  movzx ecx,word ptr [CharBuffer]
  pop ecx
  pop ebx
  movzx ecx,word ptr [eax+ecx*0x2+0xD8]
  jmp e2569_Ret_BattleArteUnison
e2569_ArteSphereCheck:
  movzx ebx,byte ptr [ebx+0x1322]
  dec ebx
  imul ebx,0xE
  push edx
  mov edx, DWORD PTR [TOS.exe+0x6d3f68]
  lea ecx,[edx+0x114]
  pop edx
  add ebx,ecx
  pop ecx
  movzx ecx,word ptr [ebx+ecx*0x2]
  pop ebx
  jmp e2569_Ret_BattleArteUnison

// Arte Sphere Use Unison
TOS.exe+0x722f8:
  jmp e2569_Mem_BattleArteUnison
  nop #3
e2569_Ret_BattleArteUnison:

// ArtesSphere / CT 2557: Trigger Fix

// Trigger Fix
TOS.exe+0x2111d7:
  nop #4
  mov edi,0x00000400

// Trigger Fix
TOS.exe+0x2111eb:
  nop #4
  mov ebx,0x00000800

// ArtesSphere / CT 2558: R-Stick Shortcuts (Rebinds LT and RT)

// R-Stick Shortcuts (Rebinds LT and RT)
mem_payload_e2558_Mem_DisableRStickX:
e2558_Mem_DisableRStickX:

// R-Stick Shortcuts (Rebinds LT and RT)
mem_payload_e2558_Mem_DisableRStickY:
e2558_Mem_DisableRStickY:

// R-Stick Shortcuts (Rebinds LT and RT)
mem_payload_e2558_Mem_DisableRStickX:
  cmp byte ptr [BattleState],0x0
  je e2558_Code_DisableRStickX
  xor edx,edx
e2558_Code_DisableRStickX:
  mov [ecx+0x20],edx
  mov edx,[eax+0x2C]
  jmp e2558_Ret_DisableRStickX

// R-Stick Shortcuts (Rebinds LT and RT)
TOS.exe+0x211abe:
  jmp e2558_Mem_DisableRStickX
  nop
e2558_Ret_DisableRStickX:

// R-Stick Shortcuts (Rebinds LT and RT)
mem_payload_e2558_Mem_DisableRStickY:
  cmp byte ptr [BattleState],0x0
  je e2558_Code_DisableRStickY
  test byte ptr [BattleMenu],0x1
  jne e2558_Code_DisableRStickY
  push ecx
  movzx ecx,byte ptr [ControlID]
  cmp byte ptr [LockRS+ecx],0x0
  pop ecx
  je e2558_NotLocked
  xor edx,edx
  jmp e2558_Code_DisableRStickY
e2558_NotLocked:
  push edx
  test edx,edx
  jge e2558_ObtainedABS
  neg edx
e2558_ObtainedABS:
  cmp edx,0x738E
  jl e2558_StickDeadzone
  pop edx
  cmp edx,0x0
  jl e2558_TestLow
  movzx edx,word ptr [esi+0x10]
  or dx,0x800
  jmp e2558_ReassignEnd
e2558_TestLow:
  movzx edx,word ptr [esi+0x10]
  or dx,0x400
e2558_ReassignEnd:
  mov [esi+0x10],edx
  jmp e2558_ClearStickY
e2558_StickDeadzone:
  pop edx
e2558_ClearStickY:
  xor edx,edx
e2558_Code_DisableRStickY:
  mov [ecx+0x24],edx
  mov edx,[eax+0x30]
  jmp e2558_Ret_DisableRStickY

// R-Stick Shortcuts (Rebinds LT and RT)
TOS.exe+0x211ac4:
  jmp e2558_Mem_DisableRStickY
  nop
e2558_Ret_DisableRStickY:

// ArtesSphere / CT 2559: Remove Shortcut Fix (Fixes Removing a Shortcut Arte from the Menu)

// Remove Shortcut Fix (Fixes Removing a Shortcut Arte from the Menu)
mem_payload_e2559_Mem_RemoveShortcutFix:
e2559_Mem_RemoveShortcutFix:

// Remove Shortcut Fix (Fixes Removing a Shortcut Arte from the Menu)
mem_payload_e2559_Mem_RemoveShortcutFix:
  mov [edi],dx
  cmp ecx,0x4
  jb e2559_Code_RemoveShortcutFix
  push ecx
  mov ch,0x8
  sub ch,cl
  movzx ecx,ch
  add edi,ecx
  pop ecx
  mov byte ptr [edi],0x0
e2559_Code_RemoveShortcutFix:
  mov DWORD PTR [ebp-0x08],0x0000001C
  jmp e2559_Ret_RemoveShortcutFix

// Remove Shortcut Fix (Fixes Removing a Shortcut Arte from the Menu)
TOS.exe+0x125348:
  jmp e2559_Mem_RemoveShortcutFix
  nop #5
e2559_Ret_RemoveShortcutFix:

// ArtesSphere / CT 2560: R-Stick Shortcut Icons

// R-Stick Shortcut Icons
TOS.exe+0x122417:
  mov DWORD PTR [esp+0x68],0x2A0029

// R-Stick Shortcut Icons
TOS.exe+0x1223ff:
  mov DWORD PTR [esp+0x5C],0x2A0029

// ManualOverLimit / CT 785: [Manual Over Limit] (Requires Artes Sphere)
