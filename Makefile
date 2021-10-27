.PHONY: all

all: txt/lat_score.tsv.gz


txt/censored: 01_censorList.bash
	./01_censorList.bash

txt/id_date.txt: 02_subjInfo.bash
	./02_subjInfo.bash

txt/lat_score.tsv.gz: txt/id_date.txt 04.1_eyetracking_score_lat.bash
	./04.1_eyetracking_score_lat.bash

txt/CogLong_et_ts_tsv.tar.xz: 04.2_et_raw.bash
	./04.2_et_raw.bash

txt/wasi.txt txt/rist.txt: 05_wasi.bash txt/id_date.txt
	./05_wasi.bash

txt/task_version.txt: 04.3_task_info.bash
	./04.3_task_info.bash
