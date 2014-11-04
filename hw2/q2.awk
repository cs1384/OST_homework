BEGIN{FS=",";stateN=0;pollN=0}
{if(state[$1]==0){state[$1]=1;stateN=stateN+1;}pollN=pollN+1}
END{print pollN/stateN}



