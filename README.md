# devops-netology
Новая строка
1. В файле .terraform/.gitignore все строки, начинающиеся с #, служат комментарием.
2. **/.terraform/* - означает, что во всех папках будет идти поиск папки terraform и в ней будут игнорироваться все файлы
3. *.tfstate - исключает все файлы в папке .terraform с расширением tfstate
4. *.tfstate.* - исключает в папке .terraform все файлы с любым расширением, в названии которых есть .tfstate.
5. crash.log - исключает в папке .terraform файл crash.log
6. *.tfvars - исключает все файлы в папке .terraform с расширением .tfvars
7. override.tf - исключает в папке .terraform файл override.tf
8. override.tf.json - исключает в папке .terraform файл override.tf.json
9. *_override.tf - исключает в папке .terraform с любым количеством символов в начале названия, но содержащих в конце _override.tf
10. *_override.tf.json - исключает в папке .terraform с любым количеством символов в начале названия, но содержащих в конце _override.tf.json
11. .terraformrc - исключает в папке .terraform файл .terraformrc
12. terraform.rc - исключает в папке .terraform файл terraform.rc