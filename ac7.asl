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

init
{
    vars.m6gotBaseReq = false;
    vars.m6gotSRank = false;
    vars.m11gotBaseReq = false;
    vars.m11gotSRank = false;
    vars.totalIGT = 0;
}

start
{
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
    // split if the score variable gets cleared out (transition to mission results)
    if(current.score==0 && old.score>current.score){
        return true;
    }

    // Mission sub splits
    if(current.missionID==6){
        // Base requirement
        if(current.score >= 24000){
            if(!vars.m6gotBaseReq){
                vars.m6gotBaseReq = true;
                return true;
            }
        }
        // S Rank
        if(current.score >= 27000){
            if(!vars.m6gotSRank){
                vars.m6gotSRank = true;
                return true;
            }
        }
    }

    if(current.missionID==6){
        // Base requirement
        if(current.score >= 30000){
            if(!vars.m11gotBaseReq){
                vars.m11gotBaseReq = true;
                return true;
            }
        }
        // S Rank
        if(current.score >= 40000){
            if(!vars.m11gotSRank){
                vars.m11gotSRank = true;
                return true;
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