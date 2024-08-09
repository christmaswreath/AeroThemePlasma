#pragma once


void getColorBalances(int sliderPosition, int &primaryBalance, int &secondaryBalance, int &blurBalance)
{
	auto roundNum = [&](double a) -> int {
		double rem = a - (int)a;
		return (int)a + (rem >= 0.5f ? 1 : 0);
	};
	int pB = 0, sB = 0, bB = 0;
	int x = sliderPosition;
	//primary
	if(x >= 26 && x < 103)
	{
		pB = 5;
	}
	else if(x >= 103 && x < 188)
	{
		pB = roundNum(0.776471*x - 74.9765);
	}
	else if(x == 188) 
	{
		pB = 71;
	}
	else if(x >= 189 && x <= 217)
	{
		pB = roundNum(0.535714*x - 31.25);
	}

	//secondary
	if(x >= 26 && x < 102)
	{
		sB = roundNum(0.526316*x - 8.68421);
	}
	else if(x >= 102 && x < 189)
	{
		sB = roundNum(-0.517241*x + 97.7586);
	}
	else if(x >= 189 && x <= 217)
	{
		sB = 0;
	}

	//blur 
	if(x >= 26 && x < 102)
	{
		bB = roundNum(-0.526316*x + 103.6842);
	}
	else if(x >= 102 && x < 188)
	{
		bB = roundNum(-0.255814*x + 76.093);
	}
	else if(x == 188)
	{
		bB = 28;
	}
	else if(x >= 189 && x <= 217)
	{
		bB = roundNum(-0.535714*x + 131.25);
	}

	printf("%d %d %d\n", pB, sB, bB);
	
	primaryBalance = pB;
	secondaryBalance = sB;
	blurBalance = bB;
}
