_:
{
	programs.yazi = {
		enable = true;
		keymap = {
			manager.prepend_keymap = [
				{
					on   = [ "<C-s>" ];
					run  = "shell \"$SHELL\" --block --confirm";
					desc = "Open shell here";
				}
			];
		};
	};
}
