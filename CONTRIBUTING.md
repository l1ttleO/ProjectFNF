Contributing to ProjectFNF
==========================
ProjectFNF requires a different method of contributing changes using patches. However, you should not worry as the process is still pretty simple.

## Requirements

Before you start PRing changes, you'll need the following:

- Haxe version 4.2.4 or higher;
- `git` (required to make and apply patches; commit and push changes);
- a GitHub account (required to make the pull request and update it if needed).

## Understanding Patches

ProjectFNF consists of patches that are applied on the Psych Engine codebase. This is done to simplify development.

Because of how heavily `git` is used, you must have a basic understanding of it. A basic tutorial can be found here:
<https://git-scm.com/docs/gittutorial>.

Assuming you have already forked the repository and cloned it to your local machine:

1. If you want to *modify* an existing patch (see below), stop following this list. You do not need apply all patches;
1. Apply all existing patches using the batch file `art/apply-existing-patches.bat`;
1. Done! You're ready to start writing code!

## Adding patches

If you want to implement new functionality, you want to *add* a new patch.
Adding patches to ProjectFNF is very simple:

If your changes involve the `assets` folder, you must put new/replaced assets in `patches/assets`, making sure to preserve the directory structure. After that:

1. Modify the `source/` folder as you need;
1. Test your changes thoroughly before committing and patching, as fixing up might be difficult!
1. Before committing, discard all changes to the `assets/` folder
1. Run `git commit -a` with the desired patch message. Do not push the newly created commit!
1. Run the batch file `art/create-patch-from-commit.bat`;
1. PR the generated patch files back to this repository (push the **patch file**, not the commit the patch was created from).


## Modifying patches

If you want to improve upon existing functionality already added in a patch, you want to *edit* a patch.
This is a bit more complex:

Assuming you did **not** apply all patches (if you did, run `art/revert-codebase.bat`):

1. Use `art/apply-patches-with-pauses.bat` to apply all patches up to the one you want to modify. Don't close the command prompt yet!
1. Run `git reset @~`
1. Modify the changes as you need
1. Run 
```console
git commit -a --author "ORIGINAL_USERNAME <ORIGINAL_EMAIL> -m "ORIGINAL_MESSAGE
>
YOUR_USERNAME: <description of your changes>
> 
> 
Co-authored-by: YOUR_USERNAME <YOUR_GITHUB_EMAIL>"
```
Example: 
```console
git commit -a --author "l1ttleO <l1ttleofficial@outlook.com>" -m "Add visual option 'Vignette'
>
BeastlyGhost: fixed a crash if this option is enabled mid-song
>
>
Co-authored-by: BeastlyGhost <45212377+BeastlyGhost@users.noreply.github.com>
```
1. Run the batch file `art/create-patch-from-commit.bat`, replace the patch you applied in step 1 with your just-baked file;
1. Apply the remaining patches (NOTE: If you see `Falling back to a 3-way merge` and/or you encounter conflicts (fix them *before* replacing the patch), you must use `art/create-patch-from-commit.bat` to re-create the patch and replace it.)
1. PR patch file back to this repository (push the **patch file**, not the commit the patch was created from).
