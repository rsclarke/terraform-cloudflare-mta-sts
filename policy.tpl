version: STSv1
mode: ${mode}
%{for host in mx ~}
mx: ${host}
%{endfor ~}
max_age: ${max_age}
