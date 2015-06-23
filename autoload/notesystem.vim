function! notesystem#NewNote(noteName)

    " sanitise note name
    let l:noteFname = substitute(a:noteName, " ", "_", "g")
    let l:noteFname = substitute(l:noteFname, "\\", "", "g")
    let l:noteFname = tolower(l:noteFname.".md")

    " get the target directory of the new note
    let l:cwd = getcwd()
    exec 'lcd ' . g:notes_dir
    call inputsave()
    let l:noteDir = input('Note dir: ', './', 'dir')
    let l:noteDir = substitute(l:noteDir, '/ *$', '', '')
    call inputrestore()
    exec 'lcd ' . l:cwd

    " open a new buffer for the new note and insert the title
    let l:target = l:noteDir . '/' . l:noteFname
    exec 'e ' . l:target
    call setline(line('.'), getline('.') . '# ' . a:noteName)

    " create a link and put it in register l
    let l:link = printf("[%s](%s)", a:noteName, l:target)
    let @l = l:link

endfunction


function! notesystem#InsertImage(sourcePath)
python << endpython
import vim
import os
import shutil
from subprocess import call

__img_dir = "img"
__assets_dir = "assets"


def copy_file(source, target):
    target_dir = os.path.split(target)[0]
    if not os.path.exists(target_dir):
        os.mkdir(target_dir)
    shutil.copy(source, target)


def unique_fname(source_file, img_dir, assets_dir):
    source_base, ext = os.path.splitext(source_file)
    idup = 0

    if ext == ".pdf":
        pdf = os.path.join(assets_dir, source_file)
        pdf_base = os.path.splitext(pdf)[0]
        img = os.path.join(img_dir, source_file[:-4]+".png")
        img_base = os.path.splitext(img)[0]

        while os.path.exists(pdf):
            idup += 1
            pdf = pdf_base + "-{:d}".format(idup) + ".pdf"
            img = img_base + "-{:d}".format(idup) + ".png"
            while os.path.exists(img):
                idup += 1
                pdf = pdf_base + "-{:d}".format(idup) + ".pdf"
                img = img_base + "-{:d}".format(idup) + ".png"

        return os.path.split(pdf)[1]

    else:
        img = os.path.join(img_dir, source_file)
        img_base = os.path.splitext(img)[0]

        while os.path.exists(img):
            idup += 1
            img = img_base + "-{:d}".format(idup) + ext

        return os.path.split(img)[1]

    print "unique img: ",target

# are we in a notes dir, or simply writing a standalone doc?
cur_dir = vim.eval("expand('%:p:h')")
notes_dir = vim.eval("g:notes_dir")

if notes_dir == -1:
    pass
elif cur_dir == notes_dir:
    __img_dir = "./"+__img_dir
    __assets_dir = "./"+__assets_dir
elif cur_dir.count(notes_dir) >= 1:
    split_path = cur_dir.replace(notes_dir+"/", "").split("/")
    rel_path = ""
    for p in split_path:
        rel_path += "../"
    __img_dir = os.path.join(rel_path, __img_dir)
    __assets_dir = os.path.join(rel_path, __assets_dir)

img_dir = os.path.join(cur_dir, __img_dir)
assets_dir = os.path.join(cur_dir, __assets_dir)
links = ""

source_path_list = str(vim.eval("a:sourcePath"))
source_path_list = source_path_list.replace(r"\ ", "&")
source_path_list = source_path_list.rstrip(" ")
source_path_list = source_path_list.split(" ")

print source_path_list

for source_path in source_path_list:

    source_path = os.path.expanduser(source_path.replace(r"&", " "))

    # get all of the relevant paths
    source_file = os.path.split(source_path)[1]
    source_ext = os.path.splitext(source_file)[1]

    # generate unique target filename
    target_file = unique_fname(source_file, img_dir, assets_dir)

    # if this is a pdf then we want to copy the original into the assets folder and convert the pdf to a png
    if source_ext == '.pdf':
        target_pdf = os.path.join(assets_dir, target_file)
        target_png = os.path.join(img_dir, target_file[:-4]+".png")

        copy_file(source_path, target_pdf)
        if not os.path.exists(img_dir):
            os.mkdir(img_dir)

        ret_code = call(['convert', '-units', 'PixelsPerInch', '-density', '80', source_path, target_png])
        if ret_code:
            print "Failed to convert pdf!"

        # generate the relative markdown link
        target_pdf = os.path.join(__assets_dir, target_file)
        target_png = os.path.join(__img_dir, target_file[:-4]+".png")
        links += " [![]({:s})]({:s})".format(target_png, target_pdf)

    else:
        target = os.path.join(img_dir, target_file)
        copy_file(source_path, target)
        # generate the relative markdown link
        target = os.path.join(__img_dir, target_file)
        links += " ![]({:s})".format(target)

vim.command("return '{:s}'".format(links[1:])) # return
endpython
endfunction

function! notesystem#GrepNotes(regex)
    exec 'Ag! -G "md|rst|taskpaper" ' . a:regex . ' '. fnameescape(g:notes_dir)
endfunction
