[control_plane]
%{ for ip in control_plane_ips ~}
${ip}
%{ endfor ~}

[workers]
%{ for ip in worker_ips ~}
${ip}
%{ endfor ~}

[k3s_cluster:children]
control_plane
workers

[k3s_cluster:vars]
ansible_user=telemaco
ansible_ssh_private_key_file=~/.ssh/hcloud
ansible_python_interpreter=/usr/bin/python3
