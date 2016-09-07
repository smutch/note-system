import vim
from unicodedata import normalize
import re
import os
from subprocess import call
import shlex
import shutil

_punct_re = re.compile(r'[\t !"#$%&\'()*\-/<=>?@\[\\\]^_`{|},.]+')


def slugify(text, delim=u'-'):
    """Generates an ASCII-only slug."""
    text = str(text)
    result = []
    for word in _punct_re.split(text.lower()):
        word = normalize('NFKD', word).encode('ascii', 'ignore')
        if word:
            result.append(word.decode('ascii'))
    slug = delim.join(result)
    vim.command("let l:slug = '" + slug + "'")
    return slug


def _unique_asset_name(note_dir, asset):
    _, asset = os.path.split(asset)
    root, ext = os.path.splitext(asset)
    root = slugify(root)
    asset = root + ext
    assets_dir = os.path.join(note_dir, vim.eval('g:notes_assets_dir'))

    fname = os.path.exists(os.path.join(assets_dir, asset))
    idup = 0
    while os.path.exists(fname):
        idup += 1
        fname = os.path.join(assets_dir, root+"-{:d}".format(idup)+ext)

    return fname


def _copy_file(source, target):
    target_dir, _ = os.path.split(target)
    if not os.path.exists(target_dir):
        os.mkdir(target_dir)
    shutil.copy(source, target)


def insert_assets(sources):
    sources = sources.rstrip(" ")
    sources = shlex.split(sources)
    links = []
    for source in sources:
        # get the relevant paths
        note_dir, _ = os.path.split(vim.current.buffer.name)
        target = _unique_asset_name(note_dir, source)

        # copy the asset
        _copy_file(source, target)

        # if it's a pdf then create a png copy
        root, ext = os.path.splitext(target)
        if ext == '.pdf':
            target_png = root + '.png'
            ret_code = call(['convert', '-units', 'PixelsPerInch', '-density', '80', '-append', source, target_png])
            if ret_code:
                print("Failed to convert pdf!")

        # generate a relative markdown link
        target = os.path.relpath(target, note_dir)
        try:
            target_png = os.path.relpath(target_png, note_dir)
            link = "[![]({:s})]({:s})".format(target_png, target)
        except:
            link = "![]({:s})".format(target)
        links.append(link)

    links = "\n".join(links)
    vim.command("return '{:s}'".format(links))
    return links
