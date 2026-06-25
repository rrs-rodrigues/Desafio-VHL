Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.box_check_update = false
    #MASTER
    config.vm.define "master" do |master|
        master.vm.hostname = "master"
        master.vm.network "private_network", ip: "192.168.56.10"
        master.vm.network "forwarded_port", guest: 6443, host: 6443

        master.vm.provider "virtualbox" do |vb|
            vb.name = "k8s-master"
            vb.memory = "2048"
            vb.cpus = 2
        end

        master.vm.provision "shell", path: "scripts/setup-master.sh"
    end

    #WORKER
    config.vm.define "worker" do |worker|
        worker.vm.hostname = "worker"
        worker.vm.network "private_network", ip: "192.168.56.11"

        worker.vm.provider "virtualbox" do |vb|
            vb.name = "k8s-worker"
            vb.memory = "1024"
            vb.cpus = 1
        end

        worker.vm.provision "shell", path: "scripts/setup-worker.sh"
    end
end