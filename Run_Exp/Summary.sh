min_n=1
max_n=8

#echo "Here is the summary of all the computations:"
for num_file in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28
do
	echo "File ${num_file}:"

	#######################################################################
	######################### Result for Symbolic #########################
	#######################################################################
	File=Summary.py
	echo "import numpy as np" > $File
	echo "" >> $File
	echo "L_time_${num_file} = []" >> $File
	echo "L_step_${num_file} = []" >> $File
	computation_done=false
	echo "Symbolic computations:"
	for i in `seq $min_n $max_n`
	do
		TimeSummary=Result/Result_Symbolic/Summary${num_file}/TimeSummary/Time_${num_file}_n_${i}
		if test -f $TimeSummary
		then
			computation_done=true
			echo -n "L_time_${num_file}_n_${i} = [" >> $File
			count=$( grep -c -Eo '[0-9\.]+s e' $TimeSummary)
			countTimeout=$( grep -c -Eo 'Timeout' $TimeSummary)
			for j in `seq 1 $count`
			do
				grep -Eo '[0-9\.]+s e' $TimeSummary | head -$j | tail -1 | echo -n $(grep -Eo '[0-9\.]+') >> $File
				if [ $j = $count ] && [ $countTimeout = 0 ]
				then :
				else echo -n "," >> $File
				fi
			done
			for j in `seq 1 $countTimeout`
			do
				echo -n '1000' >> $File
				if [[ $j = $countTimeout ]]
				then :
				else echo -n "," >> $File
				fi
			done
			echo "]" >> $File
			echo "" >> $File
			echo "L_time_${num_file}.append(($i,L_time_${num_file}_n_${i},$countTimeout))" >> $File
			
			nb_comp=$(($count+$countTimeout))
			echo -n "L_step_${num_file}_n_${i} = [" >> $File
			for j in `seq 1 ${nb_comp}`
			do
				Res=Result/Result_Symbolic/Summary${num_file}/DetailedSummary/Res_${num_file}_n_${i}_test_${j}
				countSteps=$( grep -c -Eo 'found new dfa:' $Res)+1
				echo -n "${countSteps}" >> $File
				if [[ $j = ${nb_comp} ]]
				then :
				else echo -n "," >> $File
				fi
			done
			echo "]" >> $File
			echo "" >> $File
			echo "L_step_${num_file}.append(($i,L_step_${num_file}_n_${i}))" >> $File
		fi
	done
	if [ "$computation_done" = false ]
	then echo "No Symbolic compuation done with this file"
	fi
	#echo "Done!"
	#echo ""
	echo "L_summary_${num_file} = [(L_time_${num_file}[i][0],len(L_time_${num_file}[i][1]),np.mean(L_time_${num_file}[i][1]),np.std(L_time_${num_file}[i][1]),np.mean(L_step_${num_file}[i][1]),np.std(L_step_${num_file}[i][1]),L_time_${num_file}[i][2]) for i in range(len(L_time_${num_file}))]" >> $File
	echo "" >> $File
	echo "for x in L_summary_${num_file}:" >> $File
	#echo -e -n ' \t ' >> $File
	echo "    i = x[0]" >> $File
	echo "    l = x[1]" >> $File
	echo "    mean_time = round(x[2],3)" >> $File
	echo "    var_time = round(x[3],3)" >> $File
	echo "    mean_step = round(x[4],3)" >> $File
	echo "    var_step = round(x[5],3)" >> $File
	echo "    t = x[6]" >> $File
	echo "    print(str(i),':','Time:',mean_time,'+/-',var_time,', Timeout:',t,', Step:',mean_step,'+/-',var_step)"  >> $File
	python3 $File
	rm -f $File
	echo ""

	##################################################################
	######################### Result for ILP #########################
	##################################################################

	File=Summary.py
	echo "import numpy as np" > $File
	echo "" >> $File
	echo "L_time_${num_file} = []" >> $File
	computation_done=false
	echo "ILP computations:"
	for i in `seq $min_n $max_n`
	do
		TimeSummary=Result/Result_ILP/Summary${num_file}/TimeSummary/Time_${num_file}_n_${i}
		if test -f $TimeSummary
		then
			computation_done=true
			echo -n "L_time_${num_file}_n_${i} = [" >> $File
			count=$( grep -c -Eo '[0-9\.]+s e' $TimeSummary)
			countTimeout=$( grep -c -Eo 'Timeout' $TimeSummary)
			for j in `seq 1 $count`
			do
				grep -Eo '[0-9\.]+s e' $TimeSummary | head -$j | tail -1 | echo -n $(grep -Eo '[0-9\.]+') >> $File
				if [ $j = $count ] && [ $countTimeout = 0 ]
				then :
				else echo -n "," >> $File
				fi
			done
			for j in `seq 1 $countTimeout`
			do
				echo -n '1000' >> $File
				if [[ $j = $countTimeout ]]
				then :
				else echo -n "," >> $File
				fi
			done
			echo "]" >> $File
			echo "" >> $File
			echo "L_time_${num_file}.append(($i,L_time_${num_file}_n_${i},$countTimeout))" >> $File
			#echo "Done with n = ${i}"
		fi
	done
	if [ "$computation_done" = false ]
	then echo "No ILP compuation done with this file"
	fi
	#echo "Done!"
	#echo ""
	echo "L_time_${num_file}_res = [(L_time_${num_file}[i][0],len(L_time_${num_file}[i][1]),np.mean(L_time_${num_file}[i][1]),np.std(L_time_${num_file}[i][1]),L_time_${num_file}[i][2]) for i in range(len(L_time_${num_file}))]" >> $File
	echo "" >> $File
	echo "for x in L_time_${num_file}_res:" >> $File
	#echo -e -n ' \t ' >> $File
	echo "    i = x[0]" >> $File
	echo "    l = x[1]" >> $File
	echo "    mean = round(x[2],3)" >> $File
	echo "    var = round(x[3],3)" >> $File
	echo "    t = x[4]" >> $File
	echo "    print(str(i),':','Time:',mean,'+/-',var,', Timeout:',t)"  >> $File
	python3 $File
	rm -f $File
	echo ""
	
	############################################################################
	######################### Result for Approximation #########################
	############################################################################
	File=Run_Exp/Summary.py
	echo "import numpy as np" > $File
	echo "" >> $File
	echo "Heuristic algorithm + Symbolic algorithm:"
	approx_done=false
	for i in `seq $min_n $max_n`
	do
		TimeSummary=Result/Result_Heuristic_Approximation/Summary${num_file}/TimeSummary/Time_${num_file}_n_${i}
		if test -f $TimeSummary
		then
			approx_done=true
			echo -n "L_${num_file}_n_${i} = [" >> $File
			count=$( grep -c -Eo 'For approximation:' $TimeSummary)
			for j in `seq 1 $count`
			do
				Res=Result/Result_Heuristic_Approximation/Summary${num_file}/DetailedSummary/Res_${num_file}_n_${i}_test_${j}
				ResApp=Result/Result_Heuristic_Approximation/Summary${num_file}/DetailedSummary/ResApprox_${num_file}_n_${i}_test_${j}
				echo -n "[" >> $File
				grep -Eo 'For approximation: [0-9\.]+s elapsed' $TimeSummary | head -$j | tail -1 | echo -n $(grep -Eo '[0-9\.]+') >> $File
				echo -n "," >> $File
				grep -Eo 'DFA: [0-9\.]+s e|DFA: Timeout: 1000s' $TimeSummary | head -$j | tail -1 | echo -n $(grep -Eo '[0-9\.]+') >> $File
				echo -n "," >> $File
				countSteps=$(($( grep -c -Eo 'found new dfa:' $Res)+1))
				echo -n "${countSteps}," >> $File
				grep -Eo 'score  [0-9\.]+' $ResApp | head -1 | echo -n $(grep -Eo '[0-9\.]+') >> $File
				echo -n "]" >> $File
				if [ $j = $count ]
				then :
				else echo -n "," >> $File
				fi
			done
			countStartWork=0
			countTimeout=0
			for j in `seq 1 $count`
			do
				Res=Result/Result_Heuristic_Approximation/Summary${num_file}/DetailedSummary/Res_${num_file}_n_${i}_test_${j}
				if grep -q -s -Eo '[0-9\.]+s elapsed' ${Res} 
				then 
					countSteps=$( grep -c -Eo 'found new dfa:' $Res)
					if [ $countSteps = 0 ]
					then countStartWork=$(($countStartWork+1))
					fi
				else
					countTimeout=$(($countTimeout+1))
				fi
			done
			echo "]" >> $File
			echo "L_total_${num_file}_n_${i} = [x[0] + x[1] for x in L_${num_file}_n_${i}]" >> $File
			echo "L_approx_${num_file}_n_${i} = [x[0] for x in L_${num_file}_n_${i}]" >> $File
			echo "L_SAT_${num_file}_n_${i} = [x[1] for x in L_${num_file}_n_${i}]" >> $File
			echo "L_Step_${num_file}_n_${i} = [x[2] for x in L_${num_file}_n_${i}]" >> $File
			echo "t = ${countTimeout}" >> $File
			echo "s = ${countStartWork}" >> $File
			echo "l = len(L_${num_file}_n_${i})" >> $File
			echo "mean_total = round(np.mean(L_total_${num_file}_n_${i}),3)" >> $File
			echo "var_total = round(np.std(L_total_${num_file}_n_${i}),3)" >> $File
			echo "mean_approx = round(np.mean(L_approx_${num_file}_n_${i}),3)" >> $File
			echo "var_approx = round(np.std(L_approx_${num_file}_n_${i}),3)" >> $File
			echo "mean_SAT = round(np.mean(L_SAT_${num_file}_n_${i}),3)" >> $File
			echo "var_SAT = round(np.std(L_SAT_${num_file}_n_${i}),3)" >> $File
			echo "mean_step = round(np.mean(L_Step_${num_file}_n_${i}),3)" >> $File
			echo "var_step = round(np.std(L_Step_${num_file}_n_${i}),3)" >> $File
			echo "print(str($i),':','Total time:',mean_total,'+/-',var_total)" >> $File
			echo "print('    Time for approximation:',mean_approx,'+/-',var_approx)" >> $File
			echo "print('    Time for solving:',mean_SAT,'+/-',var_SAT)" >> $File
			echo "print('    Timeout when solving:',t)"  >> $File
			echo "print('    Number of steps:',mean_step,'+/-',var_step)"  >> $File
			echo "print('    Number of times the starting DFA worked (no timeout):',s)"  >> $File
			#echo "Done with n = ${i}"
		fi
	done
	if [ "$approx_done" = false ]
	then echo "No approximation done with this file"
	fi
	python3 $File
	echo ""
	rm -f $File
done
