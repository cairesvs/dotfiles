s.%:
	grep -r "$*" ~/.gradle/caches/modules-2/files-2.1/

f.%:
	find ${ROOT_DIR} -name "*$**"
