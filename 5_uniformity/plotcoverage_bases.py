#!/usr/bin/env  python

import sys
import getopt
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.backends.backend_agg import FigureCanvasAgg

# Reads per base coverages from stdin, one positive number per line
# and computes bases covered within 10%, 20%, 50%, and 75% of median
# depth
# Also computes coverage uniformity and generates plot


def main(argv):

    infile = ''
    title = ''
    bedfile = ''

    try:
        opts, args = getopt.getopt(argv, "hi:t:b:",
                                   ["ifile=", "title=", "bed="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    if len(argv) == 0:
        usage()
        sys.exit(1)

    for opt, arg in opts:
        if opt == '-h':
            usage()
            sys.exit()
        elif opt in ("-i", "--ifile"):
            infile = arg
        elif opt in ("-t", "--title"):
            title = arg
        elif opt in ("-b", "--bed"):
            bedfile = arg

    regions = {}
    with open(bedfile, 'r') as b:
        for line in b:
            toks = line.strip('\n').split()
            for i in range(int(toks[1]), int(toks[2])+1):
                regions[toks[0] + ':' + str(i)] = 1

    vals = []
    with open(infile, 'r') as f:
        for line in f:
            if line.startswith('CHR'):
                continue
            toks = line.strip('\n').split()
            if toks[0]+':'+toks[1] in regions:
                vals.append(int(toks[2]))

    median = np.median(vals)
    perc10 = 0.0
    perc25 = 0.0
    perc50 = 0.0
    perc75 = 0.0
    percgt75 = 0.0

    for v in vals:
        d = abs(v-median)
        if d <= 0.1*median:
            perc10 += 1
        elif d <= 0.25*median:
            perc25 += 1
        elif d <= 0.50*median:
            perc50 += 1
        elif d <= 0.75*median:
            perc75 += 1
        else:
            percgt75 += 1

    perc10 = perc10*100/len(vals)
    perc25 = perc25*100/len(vals)
    perc50 = perc50*100/len(vals)
    perc75 = perc75*100/len(vals)
    percgt75 = percgt75*100/len(vals)
    avg = np.average(vals)
    std = np.std(vals)

    print("%s: Average depth per base\tnumber\t%f" % (title, avg))
    print("%s: Stdev depth per base\tnumber\t%f" % (title, std))
    print("%s: Median depth per base\tnumber\t%f" % (title, median))
    print("%s: perc bases within 10 percent of median\tnumber\t%f" %
          (title, perc10))
    print("%s: perc bases within 25 percent of median\tnumber\t%f" %
          (title, perc25))
    print("%s: perc bases within 50 percent of median\tnumber\t%f" %
          (title, perc50))
    print("%s: perc bases within 75 percent of median\tnumber\t%f" %
          (title, perc75))
    print("%s: perc bases at greater than 75 percent of median\tnumber\t%f" %
          (title, percgt75))

    vals.sort()
    x = np.arange(len(vals))
    fig = plt.figure()
    ax = fig.add_subplot(111)
    line = Line2D(x, tuple(vals))
    ax.add_line(line)
    ax.set_xlim(min(x), max(x))
    ax.set_ylim(min(vals), max(vals))
    # plt.show()
    canvas = FigureCanvasAgg(fig)
    canvas.print_figure("coverage_"+title+".png")

    # Compute normalized per base coverages
    zvals = []
    for v in vals:
        z = float((v-avg)/std)
        zvals.append(z)
    figz = plt.figure()
    axz = figz.add_subplot(111)
    linez = Line2D(x, tuple(zvals))
    axz.add_line(linez)
    axz.set_xlim(min(x), max(x))
    axz.set_ylim(min(zvals), max(zvals))
    # plt.show()
    canvasz = FigureCanvasAgg(figz)
    canvasz.print_figure("normcoverage_"+title+".png")

    # Compute coverage uniformity and generate plot
    zeros = 0
    num_in_2fold = 0
    num_in_tenfold = 0
    perc90_by_perc10_perbase = np.percentile(vals, 90) / np.percentile(vals, 10)
    for c in vals:
        if c > 0:
            if c >= median/2 and c <= 2*median:
                num_in_2fold += 1
            elif c >= median/10 and c <= 10*median:
                num_in_tenfold += 1
        else:
            zeros += 1
    
    pct2fold = float(num_in_2fold*100)/len(vals)
    pct10fold = float(num_in_2fold+num_in_tenfold)*100/len(vals)
    print("%s: median per-base target coverage\tnumber\t%f" % (title, median))
    print("%s: bases with zero coverage\tnumber\t%f" % (title, zeros))
    print("%s: percent bases in 2-fold range\tnumber\t%f" %
          (title, pct2fold))
    print("%s: percent bases in 10-fold range\tnumber\t%f" %
          (title, pct10fold))
    print("%s: Ratio of 90th percentile to 10th percentile (bases)\tnumber\t%f" %
          (title, perc90_by_perc10_perbase))
    
    vals = sorted(vals, reverse=True)
    xu = np.arange(len(vals))
    figu = plt.figure()
    axu = figu.add_subplot(111)
    lineu = Line2D(xu, tuple(vals), linewidth=3, color='k')
    axu.add_line(lineu)
    linemed = plt.axhline(median, xmin=min(xu), xmax=max(xu),
                          linewidth=2, color='r')
    axu.add_line(linemed)
    linemedp2X = plt.axhline(median*2, xmin=min(xu), xmax=max(xu),
                          linewidth=2, linestyle="dashed", color='g')
    axu.add_line(linemedp2X)
    linemedm2X = plt.axhline(median/2, xmin=min(xu), xmax=max(xu),
                         linewidth=2, linestyle="dashed", color='g')
    axu.add_line(linemedm2X)
    linemedp5X = plt.axhline(median*5, xmin=min(xu), xmax=max(xu),
                         linewidth=2, linestyle="dashed", color='b')
    axu.add_line(linemedp5X)
    linemedm5X = plt.axhline(median/5, xmin=min(xu), xmax=max(xu),
                         linewidth=2, linestyle="dashed", color='b')
    axu.add_line(linemedm5X)
    linemedp10X = plt.axhline(median*10, xmin=min(xu), xmax=max(xu),
                         linewidth=2, linestyle="dashed", color='y')
    axu.add_line(linemedp10X)
    linemedm10X = plt.axhline(median/10, xmin=min(xu), xmax=max(xu),
                         linewidth=2, linestyle="dashed", color='y')
    axu.add_line(linemedm10X)
    axu.set_xlim(min(xu), max(xu))
    #axu.set_ylim(min(vals)/10, max(vals)*10)
    plt.figlegend((lineu, linemed, linemedp2X, linemedp5X, linemedp10X),
                  ('Median base coverage', 'Median='+str(median),
                   '2-fold', '5-fold', '10-fold'),
                  'lower left')
    plt.yscale('log')
    plt.grid(True)
    plt.ylabel('Median target coverage')
#    perc2fold = float(num_in_2fold*100/len(vals))
#    perc10fold = float(num_in_2fold+num_in_tenfold)*100/len(vals))

    f2fold = format(pct2fold, '.2f')
    f10fold = format(pct10fold, '.2f')
    fratio = format(perc90_by_perc10_perbase, '.2f')
    titl = "Percent bases within 2 fold range of median: " + str(f2fold) + "\nPercent bases within 10 fold range of median: " + str(f10fold) + "\nRatio of 90th percentile to 10th percentile: " + str(fratio)
    plt.title(titl,fontsize = 11, loc='center')
    canvasu = FigureCanvasAgg(figu)
    canvasu.print_figure("uniformity_"+title+".png")


def usage():
    print('plotcoverage.py \n \
           -i <input freq file>\n \
           -b <selector BED file>\n \
           -t <title>\n')
    return 0


if __name__ == "__main__":
    main(sys.argv[1:])
