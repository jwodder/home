augroup filetypedetect
au BufNewFile,BufRead *.plt,*.gnu setf gnuplot
au BufNewFile,BufRead *.wsgi      setf python
au BufNewFile,BufRead Vagrantfile setf ruby
augroup END
