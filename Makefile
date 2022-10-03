fuzzbench.tar.gz: fuzzbench.tar
	rm -f fuzzbench.tar.gz
	gzip fuzzbench.tar

lava_corpus.tar.xz:
	wget http://panda.moyix.net/~moyix/lava_corpus.tar.xz

fuzzbench.update: fuzzbench.update-uniq fuzzbench.update-base64 fuzzbench.update-md5sum
	@echo done.

fuzzbench.update-%:
	mkdir -p fuzzbench/benchmarks/coreutils-$*/
	cat benchmark.yaml | sed -e 's#@@#$*#g'  > fuzzbench/benchmarks/coreutils-$*/benchmark.yaml
	cat build.sh | sed -e 's#@@#$*#g'  > fuzzbench/benchmarks/coreutils-$*/build.sh
	cat Dockerfile | sed -e 's#@@#$*#g'  > fuzzbench/benchmarks/coreutils-$*/Dockerfile
	cat fuzzerentry.c | sed -e 's#@@#$*#g'  > fuzzbench/benchmarks/coreutils-$*/fuzzerentry.c
	cat fuzz_utils.c | sed -e 's#@@#$*#g'  > fuzzbench/benchmarks/coreutils-$*/fuzz_utils.c
	chmod +x fuzzbench/benchmarks/coreutils-$*/build.sh
	cp lava_coreutils_patch.patch fuzzbench/benchmarks/coreutils-$*/
	cp lava_corpus.tar.xz fuzzbench/benchmarks/coreutils-$*/

fuzzbench.tar: fuzzbench
	#git clone https://github.com/google/fuzzbench;
	#(cd fuzzbench && git submodule update --init )
	$(MAKE) fuzzbench.update
	tar -cf fuzzbench.tar._ fuzzbench
	mv fuzzbench.tar._ fuzzbench.tar

fuzzbench.run: fuzzbench.box
	vagrant box add fuzzbench ./fuzzbench.box
	mkdir -p artifact
	cp -r fuzzbench artifact/
	cd artifact && vagrant init fuzzbench
	cd artifact && vagrant up
	cd artifact && vagrant ssh -c 'echo "echo core >/proc/sys/kernel/core_pattern" > ~/disable-core.sh'
	cd artifact && vagrant ssh -c 'echo defscrollback 1000000 > ~/.screenrc'
	cd artifact && vagrant ssh -c 'sudo bash -x ~/disable-core.sh'
	cd artifact && vagrant ssh -c 'rsync -avz /vagrant/fuzzbench/ ~/fuzzbench/'
	cd artifact && vagrant ssh -c 'cd ~/fuzzbench; bash ~/expt.sh'

# entry
fuzzbench.box:
	vagrant up
	vagrant ssh -c 'cd ~/; zcat /vagrant/fuzzbench.tar.gz | tar -xpf -'
	#vagrant ssh -c 'cd ~/fuzzbench; make install-dependencies'
	# vagrant ssh -c 'cd ~/fuzzbench; make presubmit'
	vagrant ssh -c 'cd ~/fuzzbench; git checkout .'
	vagrant ssh -c 'cp /vagrant/expt.sh .'
	vagrant ssh -c 'cp /vagrant/local.yaml .'
	vagrant ssh -c 'docker pull gcr.io/fuzzbench/dispatcher-image:latest'
	vagrant ssh -c 'docker pull ubuntu:xenial'
	vagrant package --output ./fuzzbench.box --vagrantfile ./Vagrantfile.new
	$(MAKE) destroy

destroy:
	vagrant halt
	vagrant destroy -f

fuzzbench.destroy:
	cd artifact && vagrant halt
	cd artifact && vagrant destroy -f
	vagrant box remove fuzzbench
	rm -rf artifact

pull:
	git pull --rebase origin master

connect:
	cd artifact && vagrant ssh
