init:
	packer init .

fmt:
	packer fmt .

validate:
	packer validate .

build:
	packer init .
	rm -rf output/
	packer validate .
	packer build .

clean:
	rm -rf output/
