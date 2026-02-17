ifdef VAR_FILE
	VAR_FLAG = -var-file="$(VAR_FILE)"
else
	VAR_FLAG = 
endif

init:
	packer init .

fmt:
	packer fmt .

validate:
	packer validate $(VAR_FLAG) .

build:
	packer init .
	packer validate $(VAR_FLAG) .
	packer build $(VAR_FLAG) .

clean:
	rm -rf output-ubuntu-vm/
