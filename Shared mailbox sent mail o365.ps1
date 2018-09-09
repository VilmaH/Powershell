o365 or 2013 u9 up shared mailbox sent mail to the shared mailboxsent folder:

For emails Sent As the shared mailbox: set-mailbox <mailbox name> -MessageCopyForSentAsEnabled $True

For emails Sent On Behalf of the shared mailbox: set-mailbox <mailbox name> -MessageCopyForSendOnBehalfEnabled $True