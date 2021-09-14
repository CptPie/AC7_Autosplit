state("Ace7Game")
{
    // Current destruction score (top left) achived
    int score: 0x03A56080, 0x55C;
    // Ingametime according to the game (perfectly mirrors the mission result screen)
    float IGT: 0x03A7D0A8, 0xF8, 0x50, 0x20, 0x128, 0x24;
}

init
{
    vars.m6got24k = false;
    vars.m6got27k = false;
    vars.m11got30k = false;
    vars.m11got40k = false;
    vars.totalIGT = 0;
}

start
{
    vars.m6got24k = false;
    vars.m6got27k = false;
    vars.m11got30k = false;
    vars.m11got40k = false;
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
    //if(current.score >= 30000){
    //    if(!vars.got2k){
    //        vars.got2k = true;
    //        return true;
    //    }  
    //}
    //if (current.score >=40000){
    //    if(!vars.got4k){
    //        vars.got4k = true;
    //        return true;
    //    }
    //}
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