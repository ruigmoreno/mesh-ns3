#!/usr/bin/awk -f
{
	# $1 is the first data from the each line of txt file passed as argument
	count[x=$1]++;
	# printf ("$2 = %f\n", $2);
	v[count[x]] = $2;
	# printf ("v[index[x=%d]] = %f\n", $1, v[count[x]]);
}
END {
	##### to run the command - ./confidenceInterval.sh ci=95 nrvar=1 <file>
	
	##### format of <file>
	##### dot sample
	##### 1 0.123456

	# number of samples
	num_samples=count[x];
	
	if (ci==90) {
			t[20] = 1.729;
			t[15] = 1.761;
			t[10] = 1.833;
			t[5] = 2.132;
			t[3] = 2.920;
	}
	if (ci==95) {
		t[2] = 12.70620474;
		t[3] = 4.30265273;
		t[4] = 3.18244631;
		t[5] = 2.77644511;
		t[6] = 2.57058184;
		t[7] = 2.44691185;
		t[8] = 2.36462425;
		t[9] = 2.30600414;
		t[10] = 2.26215716;
		t[11] = 2.22813885;
		t[12] = 2.20098516;
		t[13] = 2.17881283;
		t[14] = 2.16036866;
		t[15] = 2.14478669;
		t[16] = 2.13144955;
		t[17] = 2.11990530;
		t[18] = 2.10981558;
		t[19] = 2.10092204;
		t[20] = 2.09302405;
		t[21] = 2.08596345;
		t[22] = 2.07961384;
		t[23] = 2.07387307;
		t[24] = 2.06865761;
		t[25] = 2.06389856;
		t[26] = 2.05953855;
		t[27] = 2.05552944;
		t[28] = 2.05183052;
		t[29] = 2.04840714;
		t[30] = 2.04522964;
		t[31] = 2.04227246;
		t[32] = 2.03951345;
		t[33] = 2.03693334;
		t[34] = 2.03451530;
		t[35] = 2.03224451;
		t[36] = 2.03010793;
		t[37] = 2.02809400;
		t[38] = 2.02619246;
		t[39] = 2.02439416;
		t[40] = 2.02269092;
		t[41] = 2.02107539;
		t[42] = 2.01954097;
		t[43] = 2.01808170;
		t[44] = 2.01669220;
		t[45] = 2.01536757;
		t[46] = 2.01410339;
		t[47] = 2.01289560;
		t[48] = 2.01174051;
		t[49] = 2.01063476;
		t[50] = 2.00957524;
		t[51] = 2.00855911;
		t[52] = 2.00758377;
		t[53] = 2.00664681;
		t[54] = 2.00574600;
		t[55] = 2.00487929;
		t[56] = 2.00404478;
		t[57] = 2.00324072;
		t[58] = 2.00246546;
		t[59] = 2.00171748;
		t[60] = 2.00099538;
		t[61] = 2.00029782;
		t[62] = 1.99962358;
		t[63] = 1.99897152;
		t[64] = 1.99834054;
		t[65] = 1.99772965;
		t[66] = 1.99713791;
		t[67] = 1.99656442;
		t[68] = 1.99600835;
		t[69] = 1.99546893;
		t[70] = 1.99494542;
		t[71] = 1.99443711;
		t[72] = 1.99394337;
		t[73] = 1.99346357;
		t[74] = 1.99299713;
		t[75] = 1.99254350;
		t[76] = 1.99210215;
		t[77] = 1.99167261;
		t[78] = 1.99125440;
		t[79] = 1.99084707;
		t[80] = 1.99045021;
		t[81] = 1.99006342;
		t[82] = 1.98968632;
		t[83] = 1.98931856;
		t[84] = 1.98895978;
		t[85] = 1.98860967;
		t[86] = 1.98826791;
		t[87] = 1.98793421;
		t[88] = 1.98760828;
		t[89] = 1.98728986;
		t[90] = 1.98697870;
		t[91] = 1.98667454;
		t[92] = 1.98637715;
		t[93] = 1.98608632;
		t[94] = 1.98580181;
		t[95] = 1.98552344;
		t[96] = 1.98525100;
		t[97] = 1.98498431;
		t[98] = 1.98472319;
		t[99] = 1.98446745;
		t[100] = 1.98421695;
		t[101] = 1.98397152;
		t[102] = 1.98397152;
		t[103] = 1.98397152;
		t[104] = 1.98397152;
		t[105] = 1.98397152;
		t[106] = 1.98397152;
		t[107] = 1.98397152;
		t[108] = 1.98397152;
		t[109] = 1.98397152;
		t[110] = 1.98397152;
		t[111] = 1.98397152;
		t[112] = 1.98397152;
		t[113] = 1.98397152;
		t[114] = 1.98397152;
		t[115] = 1.98397152;
		t[116] = 1.98397152;
		t[117] = 1.98397152;
		t[118] = 1.98397152;
		t[119] = 1.98397152;
		t[120] = 1.98397152;
		t[121] = 1.98397152;
		t[122] = 1.98397152;
		t[123] = 1.98397152;
		t[124] = 1.98397152;
		t[125] = 1.98397152;
		t[126] = 1.98397152;
		t[127] = 1.98397152;
		t[128] = 1.98397152;
		t[129] = 1.98397152;
		t[130] = 1.98397152;
		t[131] = 1.98397152;
		t[132] = 1.98397152;
		t[133] = 1.98397152;
		t[134] = 1.98397152;
		t[135] = 1.98397152;
		t[136] = 1.98397152;
		t[137] = 1.98397152;
		t[138] = 1.98397152;
		t[139] = 1.98397152;
		t[140] = 1.98397152;
		t[141] = 1.98397152;
		t[142] = 1.98397152;
		t[143] = 1.98397152;
		t[144] = 1.98397152;
		t[145] = 1.98397152;
		t[146] = 1.98397152;
		t[147] = 1.98397152;
		t[148] = 1.98397152;
		t[149] = 1.98397152;
		t[150] = 1.98397152;
		t[151] = 1.98397152;
		t[152] = 1.98397152;
		t[153] = 1.98397152;
		t[154] = 1.98397152;
		t[155] = 1.98397152;
		t[156] = 1.98397152;
		t[157] = 1.98397152;
		t[158] = 1.98397152;
		t[159] = 1.98397152;
		t[160] = 1.98397152;
		t[161] = 1.98397152;
		t[162] = 1.98397152;
		t[163] = 1.98397152;
		t[164] = 1.98397152;
		t[165] = 1.98397152;
		t[166] = 1.98397152;
		t[167] = 1.98397152;
		t[168] = 1.98397152;
		t[169] = 1.98397152;
		t[170] = 1.98397152;
		t[171] = 1.98397152;
		t[172] = 1.98397152;
		t[173] = 1.98397152;
		t[174] = 1.98397152;
		t[175] = 1.98397152;
		t[176] = 1.98397152;
		t[177] = 1.98397152;
		t[178] = 1.98397152;
		t[179] = 1.98397152;
		t[180] = 1.98397152;
		t[181] = 1.98397152;
		t[182] = 1.98397152;
		t[183] = 1.98397152;
		t[184] = 1.98397152;
		t[185] = 1.98397152;
		t[186] = 1.98397152;
		t[187] = 1.98397152;
		t[188] = 1.98397152;
		t[189] = 1.98397152;
		t[190] = 1.98397152;
		t[191] = 1.98397152;
		t[192] = 1.98397152;
		t[193] = 1.98397152;
		t[194] = 1.98397152;
		t[195] = 1.98397152;
		t[196] = 1.98397152;
		t[197] = 1.98397152;
		t[198] = 1.98397152;
		t[199] = 1.98397152;
		t[200] = 1.98397152;

		if ( num_samples > 100 ) {
			t[num_samples] = 1.98397152;
		}
	}
	if (ci==99) {
		t[20] = 2.861;
		t[15] = 2.977;
		t[10] = 3.25;
		t[5] = 4.604;
		t[3] = 9.925;
	}
	sort = "sort -n";

	for ( i = 1; i <= num_samples; i++ ) {
		mean[x] = mean[x] + (v[i] / num_samples);
	}
	# printf ("mean[x] = %f\n", mean[x]);
	for( i = 1; i <= num_samples; i++ ) {
		# printf ("variance[%d] = %f\n", i, v[i]);
		variance[x] = variance[x] + (v[i] - mean[x])^2 / (num_samples-1);
	}
	# printf ("variance[x] = %f\n", variance[x]);
	# confidence interval = mean + t[num_samples] * standard_deviation / sqrt(num_samples)
	conf_interval[x] = t[num_samples] * sqrt(variance[x] / num_samples);
	printf("%f\t",x) | sort;
	printf("%f\t%f\t", mean[x], conf_interval[x]) | sort;
	printf("\n") | sort ;
	close(sort);
}
