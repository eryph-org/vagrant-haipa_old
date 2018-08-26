# if ! bundle exec vagrant box list | grep haipa 1>/dev/null; then
#     bundle exec vagrant box add haipa box/haipa.box
# fi

cd test

bundle exec vagrant up --provider=haipa
bundle exec vagrant up
bundle exec vagrant provision
bundle exec vagrant rebuild
bundle exec vagrant halt
bundle exec vagrant destroy

cd ..
