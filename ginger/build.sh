org_id=""
image_id=""
server_id=""
gingervm="/home/ubuntu/.ginger/bin/gingervm"

echo "Creating the image version"
image_version_id=$(sudo -E $gingervm image version create --org "${org_id}" --image "${image_id}" --config image.yaml --name "1.24.0")
#sudo -E $gingervm -vvv image version create --org "${org_id}" --image "${image_id}" --config image.yaml --name "1.24.0"

echo "Creating the server deployment"
sudo -E $gingervm server deployment create --org "${org_id}" --server "${server_id}" \
    --config deployment.yaml --version "${image_version_id}"

echo "Creating the data disk"
sudo -E $gingervm data-disk create --config data.yaml

echo "Delete the image version with the command below"
echo "gingervm image version delete --org ${org_id} --image ${image_id} --id ${image_version_id}"
