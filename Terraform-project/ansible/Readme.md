## To run this playbook 

### Ensure you have ansible installed.

Ensure your key pair is in this directory,

Set permision of your keypair to 400

Run `ssh-keygen`

Set permission for `.ssh/id_rsa` and `.ssh/id_rsa.pub` to 700

Then run 
` ansible-playbook -i host-inventory --private-key mykeypair.pem lol.yml -e 'ansible_python_interpreter=/usr/bin/python' `
