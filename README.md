# Identity Swap Grenade for TTT2

This is a GMod addon that adds a grenade that swaps peoples identities in TTT2.

This requires TTT2 and the Identity Disguiser for TTT2, both of which can be found on the steam workshop or on github.

## Notes

The addon allows for a timer, which resets players identities when the time elapses. This is enabled and set to 30 seconds by default. To configure it, configure the convar `ttt_id_swap_grenade_reset_timer_length`, or go into the F1 menu and find the item in the `edit equipment` section. If you set the value to zero, the timer will be disabled and identities won't be reset.

If the reset timer is enabled, switching identity or deactivating your identity with the id disguiser will stop the timer.
Also if the reset timer is enabled, upon the timers completion, you will lose the identity for the player that you swapped with entirely, unless you have had an identity disguiser this round. This is (partially) to prevent people from having the hud element the whole round, but may also make for some strategy.  

On the flilp side, if you *did* at some point have an identity disguiser, then you get to keep the identity of the player you swapped with. Just right-click with an identity disguiser again.

When the grenade explodes, it is guaranteed nobody gets the same identity that they started with. This is just so the item is more interesting and more fun.

You can swap identities with a dead body, but they can't take an alive players identity.

If a player has a different identity then normal, their *current* identity will be swapped. However, it will set the reset timer again, so you don't get another switch when the first swap grenade timer wears off.

The addon's text hud for reset timer hud is not set up for octagonal hud yet. I will remedy this soon.

Currently, this isn't published on the steam workshop. That is because I am not quite done yet. Expect a release on the workshop within a few days.
You may test this by putting it in your addons folder.
