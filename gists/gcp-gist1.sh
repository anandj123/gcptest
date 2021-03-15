#setup gist in local (https://github.com/defunkt/gist)
brew install gist
gist --login
gist gcp-gist1.sh

gist -l

#update the gist


#set gcloud config
python3 -V

gcloud config set project anand-1-291314
gcloud config set account anandj@eqxdemo.com
gcloud config list

gcloud auth application-default login
gcloud auth login
gcloud compute instances list 
