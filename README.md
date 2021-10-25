# devops-netology
Новая строка
В файле .terraform/.gitignore все строки, начинающиеся с #, служат комментарием.
**/.terraform/* - означает, что во всех папках будет идти поиск папки terraform и в ней будут игнорироваться все файлы
*.tfstate - исключает все файлы в папке .terraform с расширением tfstate
*.tfstate.* - исключает в папке .terraform все файлы с любым расширением, в названии которых есть .tfstate.
crash.log - исключает в папке .terraform файл crash.log
*.tfvars - исключает все файлы в папке .terraform с расширением .tfvars
override.tf - исключает в папке .terraform файл override.tf
override.tf.json - исключает в папке .terraform файл override.tf.json
*_override.tf - исключает в папке .terraform с любым количеством символов в начале названия, но содержащих в конце _override.tf
*_override.tf.json - исключает в папке .terraform с любым количеством символов в начале названия, но содержащих в конце _override.tf.json
.terraformrc - исключает в папке .terraform файл .terraformrc
terraform.rc - исключает в папке .terraform файл terraform.rc