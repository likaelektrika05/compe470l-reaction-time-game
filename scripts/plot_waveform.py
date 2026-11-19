import sys
# Usage: python3 scripts/plot_waveform.py sim/tb_reaction_game_top.vcd docs/sim_full_game.png
# Needs: pip install vcdvcd matplotlib. Make the .vcd first by running the full-game testbench.
from vcdvcd import VCDVCD
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
P='tb_reaction_game_top.'
names={'btnC':P+'btnC','btnU':P+'btnU','sw':P+'sw','led':P+'led[15:0]','state':P+'dut.state[2:0]','ms':P+'dut.ms_bcd[15:0]','best':P+'dut.best[15:0]'}
v=VCDVCD(sys.argv[1], signals=list(names.values()), store_tvs=True)
def tv(k): return [(t/1e5, val) for t,val in v[names[k]].tv]   # ps -> game ms (1 ms = 100 ns = 1e5 ps)
def b2i(b):
    if any(c in b for c in 'xz'): return 0
    x=int(b,2); return ((x>>12)&15)*1000+((x>>8)&15)*100+((x>>4)&15)*10+(x&15)
dig=lambda b: 0 if b in ('x','z') else int(b,2)
tend=v.endtime/1e5
rows=[('btnC\n(start / react)',tv('btnC'),dig,'d'),
      ('led[15:0]\n"GO"',tv('led'),lambda b: 0 if 'x' in b or int(b,2)==0 else 1,'d'),
      ('game_fsm\nstate',tv('state'),lambda b: 0 if 'x' in b else int(b,2),'s'),
      ('ms_counter',tv('ms'),b2i,'n'),
      ('best_score',tv('best'),b2i,'n'),
      ('sw[0]\nshow best',tv('sw'),dig,'d'),
      ('btnU\nreset',tv('btnU'),dig,'d')]
fig,axs=plt.subplots(len(rows),1,figsize=(13,9.5),sharex=True,gridspec_kw={'height_ratios':[1,1,2,2,2,1,1]})
for ax,(lab,data,f,kind) in zip(axs,rows):
    xs=[t for t,_ in data]+[tend]; ys=[f(b) for _,b in data]; ys.append(ys[-1])
    ax.step(xs,ys,where='post',color='#2a6fdb',lw=1.3)
    ax.set_ylabel(lab,rotation=0,ha='right',va='center',fontsize=9)
    ax.spines[['top','right']].set_visible(False); ax.grid(axis='x',alpha=.25)
    if kind=='d': ax.set_yticks([0,1]); ax.set_ylim(-.2,1.3)
    if kind=='s': ax.set_yticks(range(5)); ax.set_yticklabels(['READY','WAIT','GO','RESULT','EARLY'],fontsize=8); ax.set_ylim(-.5,4.5)
    if kind=='n':
        ax.set_yscale('symlog',linthresh=100); t=[0,150,250,400,1000,9999]
        ax.set_yticks(t); ax.set_yticklabels([str(x) for x in t],fontsize=8)
for x,txt in [(1700,'250 ms'),(3300,'false start\n-> Err'),(6550,'400 ms'),(9200,'150 ms\nnew best'),(17000,'no press -> 9999'),(22270,'reset')]:
    axs[0].annotate(txt,(x,1.25),ha='center',fontsize=8,color='#444',annotation_clip=False)
axs[-1].set_xlabel('game time (ms)      simulated with 1 ms = 10 clocks')
fig.suptitle('Full-game simulation (tb_reaction_game_top): 3 rounds, a false start, a no-press timeout, and a reset',fontsize=12)
fig.tight_layout(); fig.savefig(sys.argv[2],dpi=130); print('ok',tend)
