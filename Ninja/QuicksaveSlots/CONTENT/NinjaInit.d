const int Ninja_QuicksaveSlots_CurrSlot     = 0;
const int Ninja_QuicksaveSlots_UseNumbering = 1;
const string Ninja_QuicksaveSlots_Slots     = "0";
const int Ninja_QuicksaveSlots_NumSlots     = 0;
const int _Ninja_QuicksaveSlots_G1_IsUnion  = 0;
const int Ninja_QuicksaveSlots_SaveTotal    = 0;

/*
    Aus strings.d
*/

/*
 * Replace first occurrence of needle in haystack and replace it
 */
func string Ninja_QuicksaveSlots_STR_ReplaceOnce(var string haystack, var string needle, var string replace) {
    var zString zSh; zSh = _^(_@s(haystack));
    var zString zSn; zSn = _^(_@s(needle));
    if (!zSh.len) || (!zSn.len) {
        return haystack;
    };

    var int startPos; startPos = STR_IndexOf(haystack, needle);
    if (startPos == -1) {
        return haystack;
    };

    var string destStr; destStr = "";

    destStr = STR_Prefix(haystack, startPos);
    destStr = ConcatStrings(destStr, replace);
    destStr = ConcatStrings(destStr, STR_Substr(haystack, startPos+zSn.len, zSh.len-(startPos+zSn.len)));

    return destStr;
};


/*
 * Replace all occurrences of needle in haystack and replace them
 */
func string Ninja_QuicksaveSlots_STR_ReplaceAll(var string haystack, var string needle, var string replace) {
    var string before; before = "";
    while(!Hlp_StrCmp(haystack, before));
        before = haystack;
        haystack = Ninja_QuicksaveSlots_STR_ReplaceOnce(before, needle, replace);
    end;
    return haystack;
};

/*
    Ende strings.d
*/

/// Gibt ein `oCSavegameInfo*` zurück
func int Ninja_QuicksaveSlots_oCSavegameManger__GetSavegame(var int slotNr) {
    MEM_Info(ConcatStrings("QuicksaveSlots: GetSaveGame(", ConcatStrings(IntToString(slotNr), ")")));
    var int saveMgr; saveMgr = MEM_GameManager.savegameManager;

    const int oCSavegameManager__GetSaveGame_G1 = 4414864; // 00435D90
    const int oCSavegameManager__GetSaveGame_G2 = 4428512; // 004392e0
    var int retVal;

    const int call = 0;
    if (CALL_Begin(call)) {
        CALL_PutRetValTo(_@(retVal));
        CALL_IntParam(_@(slotNr));
        CALL__thiscall(_@(saveMgr), MEMINT_SwitchG1G2 (oCSavegameManager__GetSaveGame_G1, oCSavegameManager__GetSaveGame_G2));

        call = CALL_End();
    };
    return +retVal;
};

func void Ninja_QuicksaveSlots_oCSavegameInfo__SetName(var int thisPtr, var string name) {
    
    MEM_Info(
        ConcatStrings("QuicksaveSlots: oCSavegameInfo__SetName(", 
            ConcatStrings(IntToString(thisPtr),
                ConcatStrings(", '", 
                    ConcatStrings(name, "')")))));
    
    const int oCSavegameInfo_name_offset = 64; // 0x40
    MEM_WriteString(thisPtr + oCSavegameInfo_name_offset, name);
};


func string Ninja_QuicksaveSlots_CleanSlotString(var string slot) {
    var string clean; clean = slot;
    clean = Ninja_QuicksaveSlots_STR_ReplaceAll(clean, " ", "");
    return clean;
};

/// Gets the current save slot.
/// To get the next slot, simply increase `Ninja_QuicksaveSlots_CurrSlot` by 1.
func int Ninja_QuicksaveSlots_GetSlot() {
    return STR_ToInt(STR_Split(Ninja_QuicksaveSlots_Slots, ",", Ninja_QuicksaveSlots_CurrSlot));
};

func int Ninja_QuicksaveSlots_GetSavedSlot() {
    if (!Ninja_QuicksaveSlots_SaveTotal) {
        return STR_ToInt(STR_Split(Ninja_QuicksaveSlots_Slots, ",", 0));
    };
    var int slot; slot = Ninja_QuicksaveSlots_CurrSlot;
    if (slot <= 0) {
        slot = Ninja_QuicksaveSlots_NumSlots;
    };
    return STR_ToInt(STR_Split(Ninja_QuicksaveSlots_Slots, ",", slot - 1));
};

func void _Ninja_QuicksaveSlots_UpdateSlot() {
    Ninja_QuicksaveSlots_CurrSlot  += 1;
    if (Ninja_QuicksaveSlots_CurrSlot >= Ninja_QuicksaveSlots_NumSlots) {
        Ninja_QuicksaveSlots_CurrSlot = 0;
    };
    MEM_SetGothOpt("NINJA_QUICKSAVESLOTS_PER_GAME", ConcatStrings(NINJA_MODNAME, "_curSlot"), IntToString(Ninja_QuicksaveSlots_CurrSlot));
};
func void _Ninja_QuicksaveSlots_UpdateSavesTotal() {
    Ninja_QuicksaveSlots_SaveTotal  += 1;
    MEM_SetGothOpt("NINJA_QUICKSAVESLOTS_PER_GAME", ConcatStrings(NINJA_MODNAME, "_total"), IntToString(Ninja_QuicksaveSlots_SaveTotal));
};

func void _Hook_Ninja_QuicksaveSlots_CGameManager_HandleEvent_Quicksave() {
    _Ninja_QuicksaveSlots_UpdateSavesTotal();
    // EAX = SlotNum
    var int slotNr; slotNr = Ninja_QuicksaveSlots_GetSlot();
    _Ninja_QuicksaveSlots_UpdateSlot();

    if (GOTHIC_BASE_VERSION == 2) {
        EAX = slotNr;
    } else {
        const int G1_Union_Addr_PushSlot = 4363196;
        if (_Ninja_QuicksaveSlots_G1_IsUnion) { MEM_WriteByte(G1_Union_Addr_PushSlot, slotNr); }
        else                                  { ESI = slotNr; };
    };

    if (Ninja_QuicksaveSlots_UseNumbering) {
        var int infoPtr; infoPtr = Ninja_QuicksaveSlots_oCSavegameManger__GetSavegame(slotNr);
        Ninja_QuicksaveSlots_oCSavegameInfo__SetName(infoPtr, IntToString(Ninja_QuicksaveSlots_SaveTotal));
    };
};

const int Ninja_QuicksaveSlots_ADDR_G1_PushSlotNr = 4363462;
func void _Hook_Ninja_QuicksaveSlots_CGameManager_HandleEvent_Quickload() {
    var int slotNr; slotNr = Ninja_QuicksaveSlots_GetSavedSlot();
    MEM_Info(ConcatStrings("QuicksaveSlots: Loading slot: ", IntToString(slotNr)));

    if (GOTHIC_BASE_VERSION == 2) {
        // EDX = SlotNum
        EDX = slotNr;
    } else {
        // PUSH 0x00 -> PUSH SLOTNR
        MEM_WriteByte(Ninja_QuicksaveSlots_ADDR_G1_PushSlotNr, slotNr);
    };
};

/// Checks all characters to be in range 0-9, aswell as > 0 and <= 20
func int Ninja_QuicksaveSlots_IsValidNumber(var string str) {
    var int len; len = STR_Len(str);
    var int ch;
    repeat(i, len); var int i;
        ch = STR_GetCharAt(str, i);
        if (ch < 48 || ch > 57) { return 0; };
    end;
    
    ch = STR_ToInt(str);
    if (GOTHIC_BASE_VERSION == 2) {
        if ((ch < 0) || (ch > 20)) {
            return 0;
        };
    } else {
        if ((ch < 1) || (ch > 15)) {
            return 0;
        };
    };
    return 1;
};


var int Ninja_QuicksaveSlots_isNotNewGame;
func void Ninja_QuicksaveSlots_ApplyIni() {
    const int IsNewGame = 0; IsNewGame = !Ninja_QuicksaveSlots_isNotNewGame;
    if (!Ninja_QuicksaveSlots_isNotNewGame) {
        Ninja_QuicksaveSlots_isNotNewGame = 1;
    };

    if (!MEM_GothOptExists("NINJA_QUICKSAVESLOTS", "Enabled")) {
        MEM_SetGothOpt("NINJA_QUICKSAVESLOTS", "Enabled", "1");
	};
    if (!MEM_GothOptExists("NINJA_QUICKSAVESLOTS", "Slots")) {
        if (GOTHIC_BASE_VERSION == 2) { MEM_SetGothOpt("NINJA_QUICKSAVESLOTS", "Slots", "15,16,17,18,19,20"); }
        else                          { MEM_SetGothOpt("NINJA_QUICKSAVESLOTS", "Slots", "10,11,12,13,14,15"); };
	};
    if (!MEM_GothOptExists("NINJA_QUICKSAVESLOTS", "UseNumbering")) {
        MEM_SetGothOpt("NINJA_QUICKSAVESLOTS", "UseNumbering", "1");
	};
    if (!MEM_GothOptExists("NINJA_QUICKSAVESLOTS_PER_GAME", ConcatStrings(NINJA_MODNAME, "_total"))) {
        MEM_SetGothOpt("NINJA_QUICKSAVESLOTS_PER_GAME", ConcatStrings(NINJA_MODNAME, "_total"), "0");
	};

    var string enabled; enabled = STR_Upper(MEM_GetGothOpt("NINJA_QUICKSAVESLOTS", "Enabled"));
    if (Hlp_StrCmp(enabled, "1") == 0) && (Hlp_StrCmp(enabled, "TRUE") == 0) {
        return;
    };
    Ninja_QuicksaveSlots_CurrSlot = STR_ToInt(MEM_GetGothOpt("NINJA_QUICKSAVESLOTS_PER_GAME", ConcatStrings(NINJA_MODNAME, "_curSlot")));
    Ninja_QuicksaveSlots_SaveTotal = STR_ToInt(MEM_GetGothOpt("NINJA_QUICKSAVESLOTS_PER_GAME", ConcatStrings(NINJA_MODNAME, "_total")));

    if (IsNewGame) { // Reset on NewGame
        Ninja_QuicksaveSlots_CurrSlot  = 0;
        Ninja_QuicksaveSlots_SaveTotal = 0;
    };
    Ninja_QuicksaveSlots_UseNumbering = !!STR_ToInt(MEM_GetGothOpt("NINJA_QUICKSAVESLOTS", "UseNumbering"));
    Ninja_QuicksaveSlots_Slots        = Ninja_QuicksaveSlots_CleanSlotString(MEM_GetGothOpt("NINJA_QUICKSAVESLOTS", "Slots"));
    Ninja_QuicksaveSlots_NumSlots     = STR_SplitCount(Ninja_QuicksaveSlots_Slots, ",");

    if (Ninja_QuicksaveSlots_NumSlots == 0) { return; };

    repeat(i, Ninja_QuicksaveSlots_NumSlots); var int i;
        if (!Ninja_QuicksaveSlots_IsValidNumber(STR_Split(Ninja_QuicksaveSlots_Slots, ",", i))) {

            MEM_Info(ConcatStrings("QuicksaveSlots: Not a valid number, stopping: ", STR_Split(Ninja_QuicksaveSlots_Slots, ",", i)));
            Ninja_QuicksaveSlots_NumSlots = 0;
            return;
        };
    end;
};

func int Ninja_QuicksaveSlots_CheckAddr(var int addr, var int value) {
    // If not "8B 0D E4 E9" then it's hooked.
    return MEM_ReadInt(addr) == value;
};

/// Init-function called by Ninja
func void Ninja_QuicksaveSlots_Init() {
    // Initialize Ikarus
    MEM_InitAll();

    if (GOTHIC_BASE_VERSION == 2) {
        if (Hlp_StrCmp(MEM_GetGothOpt("GAME", "useQuickSaveKeys"), "1") == 0) {
            MEM_Info("QuicksaveSlots: [GAME]->useQuickSaveKeys is disabled.");
            return;
        };
    };

    Ninja_QuicksaveSlots_ApplyIni();

    if (Ninja_QuicksaveSlots_NumSlots == 0) { MEM_Info("QuicksaveSlots: No slots given. Patch not loading."); return; };

    // Initialize LeGo
    Lego_MergeFlags(LeGo_HookEngine);

    const int CGameManager_HandleEvent_Quicksave_G1       = 4363314; // 00429432
    const int CGameManager_HandleEvent_Quicksave_G1_Union = 4363189; // 004293B5
    const int CGameManager_HandleEvent_Quicksave_G2 = 4369979;  //0042ae3b
    if (GOTHIC_BASE_VERSION == 2) {
        HookEngineF(CGameManager_HandleEvent_Quicksave_G2, 6, _Hook_Ninja_QuicksaveSlots_CGameManager_HandleEvent_Quicksave);
    } else {
        if (Ninja_QuicksaveSlots_CheckAddr(CGameManager_HandleEvent_Quicksave_G1, -370930293)) {
            // Not already hooked
            HookEngineF(CGameManager_HandleEvent_Quicksave_G1, 6, _Hook_Ninja_QuicksaveSlots_CGameManager_HandleEvent_Quicksave);
        } else {
            // Is Hooked already (e.g. Union)
            MEM_Info("QuicksaveSlots: Quicksave is already hooked. Using Union compatible mode.");
            _Ninja_QuicksaveSlots_G1_IsUnion = 1;
            HookEngineF(CGameManager_HandleEvent_Quicksave_G1_Union, 6, _Hook_Ninja_QuicksaveSlots_CGameManager_HandleEvent_Quicksave);
        };
    };

    if (GOTHIC_BASE_VERSION == 1) {
        MemoryProtectionOverride(Ninja_QuicksaveSlots_ADDR_G1_PushSlotNr, 1);
    };
    const int CGameManager_HandleEvent_Quickload_G1 = 4363455;  //004294bf
    const int CGameManager_HandleEvent_Quickload_G2 = 4370146;  //0042aee2
    HookEngineF(MEMINT_SwitchG1G2(CGameManager_HandleEvent_Quickload_G1, CGameManager_HandleEvent_Quickload_G2),
                6,
                _Hook_Ninja_QuicksaveSlots_CGameManager_HandleEvent_Quickload);
    
    MEM_Info("  QuicksaveSlots: Initialized.");
};
