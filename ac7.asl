// NOTES FOR DEV/DEBUGGING
// Pointer base value: "Ace7Game.exe"+{first part of the address}
state("Ace7Game")
{
    // Current destruction score (top left) achived
    int score: 0x03A58680, 0x55C; // 0 when transition

    // Ingametime according to the game (perfectly mirrors the mission result screen)
    float IGT: 0x03A58680, 0x528; // undefined when transition

    // Number of kills (might be useful?)
    int kills: 0x03A58680, 0x520, 0x88, 0x5A0; // 0 when transition

    // Some sort of state?
    int state: 0x03A58680, 0x450, 0x428, 0x5A4; // undefined when transition

            // State "debugging"
            // Mission 1
            // x x x x x x x x
            // | | | | | | | \
            // | | | | | | \ - triggered as i killed all 4
            // | | | | | \ - - killed smth?
            // | | | | \ - - - 
            // | | | \ - - - - triggered as i killed all 4
            // | | \ - - - - -
            // | \ - - - - - -
            // \ - - - - - - -

    // Mission number
    int missionID: 0x03A58680, 0x470; // persists into replay

    // Pause flag
    int paused: 0x03A58680, 0x3E0; // Game pause flag (apparently different depending on the mission ... see list below)
            // M1 - 8 (1000) and 11 (1011) 
            // M2 - 5 (101) and 8 (1000)
            // M3 - 6 (110) and 9 (1001)
            // M4 - 39 (100111) and 42 (101010)
            // M5 - 13 (1101) and 16 (10000)
            // M6 - 6 (110) and 9 (1001)
            // M7 - 19 (10011) and 22 (10110)
            // M8 - 5 (101) and 8 (1000)
            // M9 - 10101 - 11000
            // M10 - 111 - 1010
            // M11 - 1101 - 10000
            // M12 - 101 - 1000
            // M13 - 101 - 1000
            // M14 - 101 - 1000
            // M15 - 10001 - 10100
            // M16 - 1011 - 1110
            // M17 - 101 - 1000
            // M18 - 110 - 1001
            // M19 - 1011011 - 1011110
            // M20 - 1101 - 10000
            // SP1 - 100011 - 100110
            // SP2 - 10000 - 10011
            // SP3 - 1001 - 1100

}

startup
{
    settings.Add("SplitterVerson",false,"Version: v1.5");
    settings.Add("SRankCheck",false,"Do you want to check for S-Ranks before splitting automatically? This will reset if no S-Rank was achived.");
    settings.Add("missionSubsplits",false,"Do you want to enable score/ace subsplits for missions?");
    settings.Add("mission6ScoreSplits",false,"Do you want to enable score subsplits for mission 6?","missionSubsplits");
    settings.Add("mission11ScoreSplits",false,"Do you want to enable score subsplits for mission 11?","missionSubsplits");
    settings.Add("ilMode",false,"Do you want to enable 'IL Mode'? In this mode the splitter will automatically reset when the mission data gets cleared. Only use this in IL runs otherwise the autosplitter will reset after every mission played.");
}


init
{
    vars.Reset = false;
    vars.m6gotBaseReq = false;
    vars.m6gotSRank = false;
    vars.m11gotBaseReq = false;
    vars.m11gotSRank = false;
    vars.totalIGT = 0;
    vars.gameRunningVal = 0;
    vars.isPaused = false;
    vars.wasPaused = false;
    vars.wasPausedCounter = 0;
}

start
{
    vars.Reset = false;
    vars.m6gotBaseReq = false;
    vars.m6gotSRank = false;
    vars.m11gotBaseReq = false;
    vars.m11gotSRank = false;
    vars.totalIGT = 0;
    vars.gameRunningVal = 0;
    vars.isPaused = false;
    vars.wasPaused = false;
    vars.wasPausedCounter = 0;
    if(old.IGT == 0 && current.IGT > old.IGT){
        return true;
    }
}

update
{
    // Pause detection
    if(current.IGT != old.IGT){
        // Hopefully save the running val somewhat persistantly
        vars.gameRunningVal=current.paused;
    }

    if(current.paused != vars.gameRunningVal) {
        // Game is currently paused
        vars.isPaused = true;
    }

    if(current.paused == vars.gameRunningVal && vars.isPaused){
        // Game is no longer paused but WAS paused
        vars.isPaused = false;
        vars.wasPaused = true;
        vars.wasPausedCounter = 100;
    }

    if (vars.wasPaused) {
        // Countdown for the wasPaused flag
        if (vars.wasPausedCounter==0){
            vars.wasPaused = false;
        } else {
            vars.wasPausedCounter = vars.wasPausedCounter -1;
        }
    }
    //print("is: "+vars.isPaused.ToString()+" was: "+vars.wasPaused.ToString()+" timer: "+vars.wasPausedCounter.ToString());
}

// TODO bug in mission 4 - i guess the end cutscene fucks smth up
// For reference https://clips.twitch.tv/PolishedConfidentAsteriskGrammarKing-F4LlBkUPOoujigoo
// Further reference https://clips.twitch.tv/AmusedBlatantBaconEleGiggle-o79R44SBwRKKCebq
// 
// Only appears in campaign?


split
{
    // Do we want to split?
    if(
        old.score>current.score 
        // The score got decresed
        && !vars.isPaused && !vars.wasPaused
    )
    {
        print("split!");
        // Do we want to split?
        if (settings["SRankCheck"])
        {
            print("SRank Splitting");
            // We have to check the S-Rank condition for each mission
            // This means we have to calc the S-Rank Score for each mission before splitting

            // Get the game variables
            TimeSpan igt = TimeSpan.FromSeconds(vars.totalIGT+current.IGT);
            int destructionScore = old.score;

            // Prepare S-Rank variables
            int sRankScoreRequirement = 0;
            TimeSpan targetTime = new TimeSpan(0);
            int timeScore = 0;
            int penalty = 0;

            // Prepare result variables
            int res = 0;
            int sRankScore = 0;

            // Saving the mission integer into a seperate variable to enable switching on it ... (god i want to cry)
            int mission = current.missionID;

            // Switch to set the relevant variables
            switch (mission)
            {
                case 1:
                    if (current.paused==8 || current.paused==11){
                        print("Misson 1");
                        sRankScoreRequirement = 20530;
                        targetTime = new TimeSpan(0,4,50);
                        timeScore = 10230;
                        penalty = 30;
                    } else if (current.paused==35 || current.paused==38) {
                        print("SP 1");
                        sRankScoreRequirement = 58000;
                        targetTime = new TimeSpan(0,17,0);
                        timeScore = 15000;
                        penalty = 300; // maybe a typo?
                    }
                    break;
                case 2:
                    if (current.paused==5 || current.paused==8){
                        print("Misson 2");
                        sRankScoreRequirement = 33050;
                        targetTime = new TimeSpan(0,6,0);
                        timeScore = 25550;
                        penalty = 50;
                    } else if(current.paused==16 || current.paused==19){
                        print("SP 2");
                        sRankScoreRequirement = 70000;
                        targetTime = new TimeSpan(0,19,0);
                        timeScore = 8100;
                        penalty = 30;
                    }
                    break;
                case 3:
                    if (current.paused==6 || current.paused==9){
                        print("Misson 3");
                        sRankScoreRequirement = 44440;
                        targetTime = new TimeSpan(0,9,0);
                        timeScore = 27640;
                        penalty = 40;
                    } else if (current.paused==9 || current.paused==12) {
                        print("SP 3");
                        sRankScoreRequirement = 117000;
                        targetTime = new TimeSpan(0,14,0);
                        timeScore = 81000;
                        penalty = 225;
                    }
                    break;
                case 4:
                    print("Misson 4");
                    sRankScoreRequirement = 50240;
                    targetTime = new TimeSpan(0,10,30);
                    timeScore = 32440;
                    penalty = 40;
                    break;
                case 5:
                    print("Misson 5");
                    sRankScoreRequirement = 34740;
                    targetTime = new TimeSpan(0,8,0);
                    timeScore = 18040;
                    penalty = 40;
                    break;
                case 6:
                    print("Misson 6");
                    if(destructionScore>27000)
                    {
                        return true;
                    }
                    break;
                case 7:
                    print("Misson 7");
                    sRankScoreRequirement = 46350;
                    targetTime = new TimeSpan(0,12,30);
                    timeScore = 40550;
                    penalty = 50;
                    break;
                case 8:
                    print("Misson 8");
                    sRankScoreRequirement = 40550;
                    targetTime = new TimeSpan(0,10,0);
                    timeScore = 12050;
                    penalty = 50;
                    break;
                case 9:
                    print("Misson 9");
                    sRankScoreRequirement = 43040;
                    targetTime = new TimeSpan(0,11,0);
                    timeScore = 31240;
                    penalty = 40;
                    break;
                case 10:
                    print("Misson 10");
                    sRankScoreRequirement = 27540;
                    targetTime = new TimeSpan(0,12,0);
                    timeScore = 19240;
                    penalty = 40;
                    break;
                case 11:
                    print("Misson 11");
                    if(destructionScore>40000)
                    {
                        return true;
                    }
                    break;
                case 12:
                    print("Misson 12");
                    sRankScoreRequirement = 49630;
                    targetTime = new TimeSpan(0,16,30);
                    timeScore = 15330;
                    penalty = 30;
                    break; 
                case 13:
                    print("Misson 13");
                    sRankScoreRequirement = 38040;
                    targetTime = new TimeSpan(0,7,0);
                    timeScore = 19240;
                    penalty = 40;
                    break;
                case 14:
                    print("Misson 14");
                    sRankScoreRequirement = 32640;
                    targetTime = new TimeSpan(0,9,0);
                    timeScore = 18040;
                    penalty = 40;
                    break;   
                case 15:
                    print("Misson 15");
                    sRankScoreRequirement = 57200;
                    targetTime = new TimeSpan(0,21,30);
                    timeScore = 21700;
                    penalty = 50;
                    break; 
                case 16:
                    print("Misson 16");
                    sRankScoreRequirement = 39040;
                    targetTime = new TimeSpan(0,18,0);
                    timeScore = 19240;
                    penalty = 40;
                    break;             
                case 17:
                    print("Misson 17");
                    sRankScoreRequirement = 44030;
                    targetTime = new TimeSpan(0,15,30);
                    timeScore = 18930;
                    penalty = 30;
                    break;
                case 18:
                    print("Misson 18");
                    sRankScoreRequirement = 37050;
                    targetTime = new TimeSpan(0,12,30);
                    timeScore = 25550;
                    penalty = 50;
                    break;
                case 19:
                    print("Misson 19");
                    sRankScoreRequirement = 67640;
                    targetTime = new TimeSpan(0,20,30);
                    timeScore = 16840;
                    penalty = 40;
                    break;
                case 20:
                    print("Misson 20");
                    sRankScoreRequirement = 36050;
                    targetTime = new TimeSpan(0,10,0);
                    timeScore = 25550;
                    penalty = 50;
                    break;
                default:
                    return false;
                    break;
            }
            // Compare IGT to Target time
            res = TimeSpan.Compare(igt,targetTime); // -1 if igt is shorter than target, 0 if igt == target, 1 if igt is longer than target
            
            if(res>1)
            {
                timeScore = timeScore - (penalty*igt.Subtract(targetTime).Seconds);
            }

            print("Time: "+timeScore.ToString());
            print("Score: "+destructionScore.ToString());

            sRankScore = timeScore+destructionScore;

            print("SRank: "+sRankScore.ToString());

            if(sRankScore>=sRankScoreRequirement)
            {
                return true;
            } else {
                vars.Reset=true;
            }
        } else {
            return true;
        }
    }  
   

    if(settings["missionSubsplits"])
    {
        if(settings["mission6ScoreSplits"])
        {
            // Mission sub splits
            if(current.missionID==6)
            {
                // Base requirement
                if(current.score >= 24000)
                {
                    if(!vars.m6gotBaseReq)
                    {
                        vars.m6gotBaseReq = true;
                        return true;
                    }
                }
                // S Rank
                if(current.score >= 27000)
                {
                    if(!vars.m6gotSRank)
                    {
                        vars.m6gotSRank = true;
                        return true;
                    }
                }
            }
        }
        
        if(settings["mission11ScoreSplits"])
        {
            if(current.missionID==11)
            {
                // Base requirement
                if(current.score >= 30000)
                {
                    if(!vars.m11gotBaseReq)
                    {
                        vars.m11gotBaseReq = true;
                        return true;
                    }
                }
                // S Rank
                if(current.score >= 40000)
                {
                    if(!vars.m11gotSRank)
                    {
                        vars.m11gotSRank = true;
                        return true;
                    }
                }
            }
        }
    }
}

gameTime
{
   if(current.IGT < old.IGT){
       vars.totalIGT += old.IGT - current.IGT;
   }
   if(current.IGT >= 0 && old.IGT == 0){
       vars.totalIGT = vars.totalIGT - current.IGT;
   }   
    return TimeSpan.FromSeconds(vars.totalIGT+current.IGT);
}

isLoading
{
    if(current.IGT == old.IGT){
        return true;
    } else{
        return false;
    }
}

reset
{
    if(settings["ilMode"]){
        // Do we want to reset?
        if(
            current.IGT < vars.totalIGT 
            // The score got 0ed - either mission ended (struct cleared) or checkpoint with score of 0 got loaded
            && !vars.isPaused && !vars.wasPaused
        ) {
        return true;
        }
    } else {
        return vars.Reset;
    }
}