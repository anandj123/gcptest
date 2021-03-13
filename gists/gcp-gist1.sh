#set gcloud config
python3 -V

gcloud config set project anand-1-291314
gcloud config set account anandj@eqxdemo.com
gcloud config list

gcloud auth application-default login
gcloud auth login
gcloud compute instances list 
