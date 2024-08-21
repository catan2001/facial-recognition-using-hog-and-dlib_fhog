____________________________________________________________________________________________________________________
# GIT NOTES!
____________________________________________________________________________________________________________________

## info repo FTN
- personal git repo: *<user>@147.91.175.165:/stud/<user>/esl*
- group y24-g00 git repo: *<user>@147.91.175.165:/stud/y24-g00/*
    
## links used: 
- https://learngitbranching.js.org/
- https://git-scm.com/
- https://www.youtube.com/watch?v=USjZcfj8yxE
- https://www.elektronika.ftn.uns.ac.rs/projektovanje-elektronskih-uredjaja-na-sistemskom-nivou/wp-content/uploads/sites/117/2018/03/git.pdf
    
## generic unnecessary commands:
- **git config --global user.name "name"** //setting up name for pc
- **git config --global email emailaddress** //setting up email for pc
- **git help command** // use HELP to check info about command

## very important commands:
- **git status** // checks the status of your files / git 
- **git log** // checks the log of your commits
- **git commit -m"comment of a log"** // it's very important to comment logs
- **git diff** // used to check the difference between commits
- **git restore --staged file_name** // untracks - restores the file to the last commit
- **git rm file_name** // better use your own terminal commands
- **git commit -m"text" -- ammend** // change name of the last commit
- **git branch name_branch** // CREATE new branch
- **git checkout name_branch** // jump to the branch you want to use
- **git merge name_branch** // merge two branches together
- **git rebase name_branch** // merge two branches so it looks as it was developed sequentially
- **git checkout name_commit** // DETACH HEAD
- **git checkout  name_branch^**// asterix ^ means how many commits you want to detach HEAD from name_branch
- **git branch** // used to see all local branches
- **git branch -a** // used to see all local and remote branches
- **git branch -r** // used to see all remote branches

## Switch to a Branch That Came From a Remote Repo
- **git pull** //to get a list of all branches from the remote, run this command
- **git checkout --track origin/my-branch-name** // run this command to switch to the branch: 

## Push to a Branch
### Does not exist on the remote 
- **git push -u origin my-branch-name** // If your local branch does not exist on the remote run this command

### Exists on the remote
- **git push** // if your local branch already exists on the remote, run this command 

## Delete Branches
### remote branches
- **git push origin --delete my-branch-name** // To delete a remote branch, run this command

### local branches 
- **git branch -d branch_name** // To delete a local branch, run this command
    **NOTE:** The -d option only deletes the branch if it has already been merged. 
    The -D option is a shortcut for --delete --force, which deletes the branch irrespective of its merged status.
    
## configuring git branche names
- Work should be separated depending on its nature, not on who will work on it.

- **Samy Dindane** : *"This is what I'd suggest:*
*Use feature branches: Most of your work should be on these topic branches, except tiny commits (such as typos, etc.).*
*When you have a feature, bug fix, or a ticket that should be processed: create a branch feat-something, and work in there.*
*Use a dev, or release-X (where X is the release's number) branch: When a feature's branch work is done, tested, and works, rebase it into dev.*
*Never commit on master, this branch should only be rebased into by the lead developer, CTO, whatever. Rebase dev's work into master when you feel it's needed.*
     
*This is (basically) how we work on a very big project. You can work without the dev branch if your project isn't big. "*
