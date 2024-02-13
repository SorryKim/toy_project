카카오클라우드스쿨 개인 토이 프로젝트 

- 시나리오

노드는 Manager, worker1,2 , storage로 4개로 구성된다.
Manager 노드의 HAproxy를 통해 worker에 존재하는 web컨테이너로 접속할 수 있다.
web컨테이너는 Manager노드에 존재하는 DB_LB컨테이너로 db의 데이터를 요청한다. DB_LB에서는 Worker노드에 존재하는 DB컨테이너들에서
적절한 컨테이너를 선택해 SELECT요청을 보내고 데이터를 WEB컨테이너에 전달한다. 모든 DB컨테이너는 Storage노드에 존재하는 Volume디렉토리를
사용하며 이 디렉토리는 cron을 사용하여 주기적으로 AWS S3에 백업을 하는 명령어를 실행하게 된다.
