terraform {
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
      version = "0.1.0"
    }
   

    #azurerm = {
     # source = "hashicorp/azurerm"
      #version = "~>2.0"
    #}
  }
}

#provider "azurerm" {
#  features {}
#}

provider "null" {
}

provider "azuredevops" {
	org_service_url = "https://dev.azure.com/${var.azdevops_org_name}/"
	personal_access_token = var.pat_token
}

data "azuredevops_project" "my_az_devops_project" {
  name = var.project_name
}

resource "azuredevops_serviceendpoint_dockerregistry" "dockerhub_registry_service_conn" {
  project_id            = data.azuredevops_project.my_az_devops_project.id
  service_endpoint_name = "dockerhubsvcconn"
  docker_username       = var.dockerhub_registry_username
  docker_email          = var.dockerhub_registry_email
  docker_password       = var.dockerhub_registry_password
  registry_type         = "DockerHub"
}

resource "azuredevops_resource_authorization" "dockerhub_registry_auth" {
  project_id  = data.azuredevops_project.my_az_devops_project.id
  resource_id = azuredevops_serviceendpoint_dockerregistry.dockerhub_registry_service_conn.id
  authorized  = true
}

resource "azuredevops_variable_group" "vars" {
  project_id   = data.azuredevops_project.my_az_devops_project.id
  name         = "VaribalesForPipeline"
  description  = "These are the varibales which holds some static value, can be used by pipelines during build/release."
  allow_access = true
  variable {
    name  = "email"
    value = var.dockerhub_registry_email
  }
  
  variable {
    name  = "imagetag"
    value = var.image_tag
  }
  
  variable {
    name  =  "name"
    value =  var.your_name
   }
  
  variable {
    name  =  "repo"
    value =  var.dockerhub_registry
   }

}

resource "null_resource" "creating_local_repo" {
  provisioner "local-exec" {
	command = "git init"
  }
  depends_on = [null_resource.creating_local_repo]
}

resource "null_resource" "adding_files_to_local_repo" {
  provisioner "local-exec" {
	command = "git add ."
  }
  depends_on = [null_resource.creating_local_repo]
}

resource "null_resource" "adding_user_email" {
  provisioner "local-exec" {
	command = "git config --global user.email \"${var.dockerhub_registry_email}\""
  }
  depends_on = [null_resource.adding_files_to_local_repo]
}

resource "null_resource" "adding_user_name" {
  provisioner "local-exec" {
	command = "git config --global user.name \"${var.your_name}\""
  }
  depends_on = [null_resource.adding_user_email]
}

resource "null_resource" "commit" {
  provisioner "local-exec" {
	command = "git commit -m \"InitialCommit\" "
  }
  depends_on = [null_resource.adding_user_name]
}

resource "null_resource" "creating_main_branch" {
  provisioner "local-exec" {
	command = "git branch -M main"
  }
  depends_on = [null_resource.commit]
}

resource "null_resource" "adding_remote_repo" {
  provisioner "local-exec" {
	command = "git remote add origin ${var.github_ci_repo_url}"
  }
  depends_on = [null_resource.creating_main_branch]
}

#resource "null_resource" "pushing_to_remote_repo" {
 # provisioner "local-exec" {
#	command = "git push -u origin main"
 # }
  #depends_on = [null_resource.adding_remote_repo]
#}




