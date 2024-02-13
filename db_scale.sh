#!/bin/bash
while true
do
    clear
    # 노드의 web 컨테이너 리소스 가져오기, container-name:cpu use(percent)
    # sshpass로 워커노드의 docker stats를 불러오는 방식이기 때문에 각 서버의 ssh 접속 정보를 입력해야 함
    ssh user1@211.183.3.101 'docker stats -a --no-stream --format "{{.Name}}:{{.CPUPerc}}" | grep web' | sed 's/..$//' > test.txt && ssh user1@211.183.3.102 'docker stats -a --no-stream --format "{{.Name}}:{{.CPUPerc}}" | grep web' | sed 's/..$//' >> test.txt && ssh user1@211.183.3.103 'docker stats -a --no-stream --format "{{.Name}}:{{.CPUPerc}}" | grep web' | sed 's/..$//' >> test.txt

    # tot에 web컨테이너 개수 저장
    tot=$(cat test.txt | grep "web" | wc -w)
    # scale 필요 시 1, pass 시 0
    check=0

    echo "==============SCALE CHECK=============="
    # test.txt에 있는 리소스 값으로 scale 지정
    for list in $(cat test.txt)
    do
        #scale cpu 기준 값
        max=40

        #한 줄씩 컨테이너 이름, cpu 리소스 불러오기
        cont_name=$(echo "$list" | cut -d":" -f1)
        used_cpu=$(echo "$list" | cut -d":" -f2)

        #소수점 제거 후 max와 비교
        for rounded_used_cpu in $(printf %.0f "$used_cpu"); do
            if [ "$rounded_used_cpu" -gt "$max" ]; then
                # 70 초과인 경우
                check=1
                echo $(echo "$cont_name" | cut -c 1-15)" CPU USE: ""$rounded_used_cpu""%"
            else
                # 70 이하인 경우
                echo $(echo "$cont_name" | cut -c 1-15)" CPU USE: ""$rounded_used_cpu""%"
            fi
        done
    done
    echo "-  -  -  -  -  -  -  -  -  -  -  -  -  "
        # scale 이 필요한 경우
        if [ $check -eq 1 ]; then
            if [ "$tot" -ge 10 ]; then
                echo "🔴 컨테이너가 10개 이상입니다. scale out을 하지 않습니다."
            else
                echo "🟠 scale out을 진행합니다."
                docker service scale web_nginx=$(expr "$tot" + 1)
            fi
        elif [ "$tot" -eq 2 ]; then
            echo "🟢 정상입니다."
        else
            echo "🟡 scale in을 진행합니다."
            docker service scale web_nginx=2
        fi
    echo "======================================="
    sleep 3
done