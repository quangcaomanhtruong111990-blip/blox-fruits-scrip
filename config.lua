local Config = {
    Team = "Pirates",
    Configuration = {
        HideallPath = false,
        blackscreen = false,
        HideGui = false,
        HopWhenIdle = true,
        AutoHop = true,
        AutoHopDelay = 60 * 60,
        FpsBoost = true,
        ["IdleCheck"] = 150,
    },
    Items = {
        AutoFullyMelees = true,
        Saber = true,
        CursedDualKatana = false,
        SoulGuitar = false,
        RaceV2 = false,
        AutoFarmFruitMastery = false,
        AutoEatFruit = 1,
        Eatlist = {}
    },
    Settings = {
        StayInSea2UntilHaveDarkFragments = false,
        ["Fragments"] = 5000
    }
}

return Config
