# cross chain rebase token
1. A protocal that allows user to deposit into a vault and in return ,receiver rebase tokens that represent their underlying balance
2. Rebase token -> balanceOf function is dynamic to show the changing balance with time.
   -- Balance increases lineraly with time
   -- mint tokens to our users every time they perform an action [minting, burning, transferring, or.. bridging]
3. Interest Rate
   -- Individually set an interest rate or each user based on some global interest rate of the protocal at the time the user deposits into the vault.
   -- This global interest rate can only decrease to incentivise/reward early adaptors.
   -- Increase token adaption