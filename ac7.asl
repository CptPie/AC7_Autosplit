// NOTES FOR DEV/DEBUGGING
// Pointer base value: "Ace7Game.exe"+{first part of the address}
state("Ace7Game")
{
    // Current destruction score (top left) achived
    int score: 0x03A56080, 0x55C;
    // Ingametime according to the game (perfectly mirrors the mission result screen)
    float IGT: 0x03A7D0A8, 0xF8, 0x50, 0x20, 0x128, 0x24;
    // Number of kills (might be useful?)
    int kills: 0x03A56080, 0x520, 0x88, 0x5A0;
    // Some sort of state?
    int state: 0x03A56080, 0x450, 0x428, 0x5A4;
    // Mission number
    // Main game: 1 through 20
    // DLC missions: 1, 2, 3 (but there has to be some other flag ...)
    int missionID: 0x03A56080, 0x470;

}

startup
{
    settings.Add("SplitterVerson",false,"Version: v1.2");
    settings.Add("SRankCheck",false,"Do you want to check for S-Ranks before splitting automatically?");
    settings.Add("missionSubsplits",false,"Do you want to enable score/ace subsplits for missions?");
    settings.Add("mission6ScoreSplits",false,"Do you want to enable score subsplits for mission 6?","missionSubsplits");
    settings.Add("mission11ScoreSplits",false,"Do you want to enable score subsplits for mission 11?","missionSubsplits");
}


init
{
    vars.Reset = false;
    vars.m6gotBaseReq = false;
    vars.m6gotSRank = false;
    vars.m11gotBaseReq = false;
    vars.m11gotSRank = false;
    vars.totalIGT = 0;
}

start
{
    vars.Reset = false;
    vars.m6gotBaseReq = false;
    vars.m6gotSRank = false;
    vars.m11gotBaseReq = false;
    vars.m11gotSRank = false;
    vars.totalIGT = 0;
    if(old.IGT == 0 && current.IGT > old.IGT){
        return true;
    }
}

split
{

    if(settings["SRankCheck"])
    {
        // Do we want to split?
        if(
            current.score==0 && old.score>current.score // Score mem location got cleared out, either score reset or misson struct got garbage collected
            && old.IGT!=current.IGT // Did the timer change? if it did, its a checkpoint restart
        )
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
                    print("Misson 1");
                    sRankScoreRequirement = 20530;
                    targetTime = new TimeSpan(0,4,50);
                    timeScore = 10230;
                    penalty = 30;
                    break;
                case 2:
                    print("Misson 2");
                    sRankScoreRequirement = 33050;
                    targetTime = new TimeSpan(0,6,0);
                    timeScore = 25550;
                    penalty = 50;
                    break;
                case 3:
                    print("Misson 3");
                    sRankScoreRequirement = 44440;
                    targetTime = new TimeSpan(0,9,0);
                    timeScore = 27640;
                    penalty = 40;
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
                    // TODO Special missions?
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
        }
    } else {
        // TODO: restart from checkpoint with a checkpoint that resets you to 0 score splits
        // split if the score variable gets cleared out (transition to mission results)
        if(
            current.score==0 && old.score>current.score // Score mem location got cleared out, either score reset or misson struct got garbage collected
            && old.IGT!=current.IGT // Did the timer change? if it did, its a checkpoint restart
        )
        {
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
    return vars.Reset;
}