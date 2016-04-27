# attack

This is a full toolkit for DCA attack. It contains the following tools:
 - `acquire.rb` ... acquire traces, filter constant entries and visualize (1/b; 2/a; 2/b/i,ii,iii),
 - `manual_view.rb` ... create custom trace visualizations (2/b/iii),
 - `addr_row_filter.rb` ... visualize and, given address & temporal ranges, filter traces (2/b/iii,iv,v,vi),
 - `attack.rb` ... run attack (3/a/ii),
 - `mark_encryption.rb` ... mark encryption in trace visualization (helps to estimate ranges),
 - `results_process.rb` ... process results (3/b),
 - `results_disp.rb` ... display results & statistics (3/c).


### Requirements

This toolkit requires [Ruby], our `BitwiseDPA` tool, `MemoryTracingTools` and their dependencies.


### Use

Run
```sh
$ ./main.rb
```
and follow instructions.

### Sample Traces & Results

In `data` directory, several results can be found. To display some, run e.g.
```sh
$ ./results_disp.rb klinec_0 1024_all
```


   [Ruby]: <https://www.ruby-lang.org>
