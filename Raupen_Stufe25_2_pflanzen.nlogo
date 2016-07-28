
extensions [array table] ; for using arrays

globals
[
  ;-----------variables for spatial settings ---------------;
  y-offset
  weltweite
  weltbreite
  size-factor ;; depending on the grid size, take care of the sizes of individuals

 ;----------- variables for simulation time ----------------;
  steps
  number-last-step ;; for calculating mortality
  simulation-length ;; sets the length of one season (in ticks) -> 6 ticks = 1 day

  Path
  ;--------------  Larva-overall-variables ------------------;
 ; conversion-factor    ; the percentage of food a larva converts into body mass
  tolerance_larva       ; the defense level of host plant at which the larva leaves the plant (if mobile)
  B-larva-max           ; maximal biomass of a larva (mass at which larvae pupate in grams)
  sum-unique-visited-pupation    ; number of plants visited by larvae (uniques) which reached pupation stage
  sum-visited-pupation
  sum-unique-visited   ; number of all plants visited by larvae (uniques per larvae)
  sum-visited          ; number of  all plants visited by larvae
  pupation-counter     ; number of larvae which reached pupation
  pupation-age-sum     ; sum of ages of larvae in ticks
  switch-counter       ; number of switching actions
  defense-switch-count ; number of switches due to the high defense-level of host plant
  defense-switch-count-now ; number of switches due to the high defense-level of host plant
  ;--------------- plant overall variables ------------------;

  B_before_growth          ;; array of the plant's above biomass (state of the beginning of the time-step, use this as buffer for further defense-level calculations
  Feeding-this-step        ;; array of the amount of plant material eaten by all caterpillars on the plant
  Defense_produced_above   ;; array which stores the above-ground costs for defense of this curent time-step
 ; intrinsic-growth-rate   ;; a constant of growth function for plants, intrinsic growth rate of mass
  B0a_max                  ;; constant: ideal maximum biomass for shoot
  B0b_max                  ;; constant: ideal maximum biomass for root
  
  PLANT-TAUS               ;; array of the taus of plants 
  numTaus                  ;; how many taus do we have
  defense_max
  LARVENPFLANZEN           ;; all plants which have larvae from the beginning on




  ;------------------- for plots, sensitivity, GA etc. ----------------------------;
  overall-mean-damage-tau1
  overall-mean-damage-tau2
  current_number_tau1 
  current_number_tau2 
  sum-tau1
  sum-tau2
  sum-above-tau1
  sum-above-tau2
  sum-residience-tau1
  sum-residience-tau2
  sum-number-plants-tau1    ;; number of plants with genotype tau1 which are currently alive
  sum-number-plants-tau2    ;; number of plants with genotype tau2 which are currently alive
  sum_damage_tau1           ;; damage caused by feeding larvae on all plants of genotype tau1 for the current time-step
  sum_damage_tau2           ;; damage caused by feeding larvae on all plants of genotype tau2 for the current time-step
  all_sum_damage_tau1       ;; sum of damage caused by feeding larvae on all plants of genotype tau1 over all time-steps
  all_sum_damage_tau2       ;; sum of damage caused by feeding larvae on all plants of genotype tau2 over all time-steps
  all-sum-above-plants      ;; above-ground biomass of all plants over all time-steps (sums up)
  sum-number-plants         ;; count of all steps in all time steps (sums up with each step)
  sum-above-plants          ;; above-ground biomasse aller pflanzen (current tick)
  sum-below-plants          ;; below-ground biomasse aller pflanzen (current tick)
  sum-plants                ;; gesamt-biomasse aller pflanzen (current tick)
    ; -> daraus dann: productivity -> sum-above-plants auch intereessant std and mean für ergebnisse
  mean-above-plants         ;; Mean plant above-ground mass current time-step
  mean-below-plants         ;; Mean plant below-ground mass current time-step
  mean-plants               ;; Mean plant mass of all plants (whole plant) current time-step
  std-above-plants          ;; standard deviation of plant above-ground mass current time-step
  std-below-plants          ;; standard deviation of plant below-ground mass current time-step
  std-plants                ;; standard deviation of plant mass of all plants (whole plant) current time-step
  
  ;---------------- for calculating mortality ---------------;
  number-alive-plants
  number-dead-plants       
  sum-number-dead-plants    
  larval-death-number           ;; number of larvas that died

  sum-residience-time           ;; how long did the larvae stay on the plants
  sum-induced-plants       ;;
  sum-damage-plants             ;; damage caused by feeding larvae on all plants for the current time-step
  all-sum-damage-plants         ;; sum of damage caused by feeding larvae on all plants over all time-steps
  ;;;;   reporters: ;;;;
  ;overall-mean-damage-plants    ;; prozentualer anteil schaden von gesamtbiomasse die insgesamt produziert wurde
  ;mean-infestation-rate-plants  ;; mean über alle ticks  (count alle pflanzen mit raupe drauf / count alle pflanzen)
  
   

  ;; what to minimize, what to maximize
  ; productivity                    ;; absolute number, maximize this or: minimize:  sum( max possible biomass) - productivity
  ; all-sum-damage-plants           ;; absolute, to be minimized
  ; overall-mean-damage-plants      ;; to be minimized, in %
  ; mean-infestation-rate-plants    ;; in %, to be minimized
]

  breed [plants plant]
  breed [larvae larva]


plants-own
[
  A_ZOI_above        ;; area of above-ground ZOI
  A_ZOI_below        ;; area of below-ground ZOI
  rad-below          ;; below-ground radius
  rad-above          ;; above-ground radius

  C_a                ;; Index for Above-ground Competition
  C_b                ;; Index for Below-ground Competition


  B_max              ;; current, realistic maximum biomass for whole plant(asymptotic biomass) 
  B                  ;; current body biomass in grams
  B-above            ;; current biomass of above-ground
  B-below            ;; current biomass of below-ground

  delta_gr_above     ;; above-ground growth rate of current time-step
  delta_gr_below     ;; below-ground growth rate of current time-step
  delta_gr           ;; current growth rate of whole plant

  r-s-ratio          ;; root/shoot ratio
  plant-dead         ;; plants with gr of 0 will have this value true
  gr-by-above        ;; growth determined by above-ground


  defense-fraction   ;; fraction of biomass which is allocated for defense, if plant is induced
  delta_defense_a    ;; defense compounds produced in the current time-step for above-ground
  delta_defense_b    ;; defense compounds produced in the current time-step for below-ground
  defense-level      ;; the current level of defense in plant (max: 0.24)
  MEMORY             ;; array of the masses of larvae for each time-step  ("Memory" of the plant)
  damage-sum         ;; sum of all damage received by feeding larvae over all time-steps (in mg)
  above-mass-produced;; sum of all above-biomass-produced over all time steps (in mg) before larval feeding

  tau                ;; defense-trait of plant
  tau-type           ;; 1 or 2 (for GA = 3 modus)
]

larvae-own
 [
   age               ;; age in days
   mobile?           ;; boolean, true, when larva can switch plants (depends on age and biomass)
   switch            ;; is the larva currently moving between plants?
   host              ;; number of the host plant (integer): from 0 to max(plants)
   biomass-larva     ;; biomass in mg (float)
   dispersal_radius  ;; distance which larva can walk to find a new plant
   last-movement-tick;; when did larvae last switch plants?
   distance-path     ;; distance of path to next host-plant
   VISITED           ;; list with numbers of plants visited
   plants-visited    ;; how many plants have been visited (same plant can be counted twice)
 ]

patches-own
[
  nb-compete-above    ;; above-ground sharing of competition
  nb-compete-below    ;; below-ground sharing of competition
]



;;;;;;;;;;;;;;;;;;;;;  plant-setting  ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;         initialisation of plants            ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to plant-setting

    set B random-normal 30000 3000 ; [mg]
    set B-above B / 2
    set B-below B / 2

    set rad-above ( B-above ^ ( 3 / 8 ) ) * ( PI ^ ( -1 / 2 ) )
    set A_ZOI_above B-above ^ ( 3 / 4 )
    set rad-below ( B-below ^ ( 3 / 8 ) ) * ( PI ^ ( -1 / 2 ) )
    set A_ZOI_below  B-below ^ ( 3 / 4 )

    ;---------------  larvae and defense -------------;
    if(level-GA = 1) ; if the GA works on individual basis -> the array of tau-values are optimised by GA
    [
       set tau array:item PLANT-TAUS who  ; funktioniert!
    ]
    if (level-GA = 2)
    [ ; else: if the GA works on population basis -> tau-range and tau-median are optimised
          set tau random-normal tau-median tau-range
          if tau < 0
          [
            let zufall random ( tau-range + 1)
            set tau zufall 
          ]
    ]
    if (level-GA = 3)
    [
         set tau tau1
         set tau-type 1
         ; if random-float 1 > 0.5  ; mit dieser Einstellung sind die Taus nicht genau gleichmäßig verteilt
         ; (ein Genotyp kann zufällig häufiger bzw. weniger häufig sein. Wird durch viele Simulationen aber ausgegelichen)
         ; [
         ;   set tau tau2
         ;]
         let number-tau1 count plants with [tau-type = 1]
         if number-tau1 >  density * frequency / 100
         [
           set tau tau2
           set tau-type 2
         ] 
    ]

    set defense-fraction defense_fraction_all
    set defense-level initial_defense_level; eigentlich 0.0
    set damage-sum 0        ;;  (in mg)
    set above-mass-produced B-above ;; (in mg) 

   ; set damage 0

    set MEMORY array:from-list n-values ( simulation-length + tau ) [0] ; initialisiere array der länge "simulation length" (+ tau, da es in der Vergangeneit startet)
    ;; initial gefüllt mit Nullen, hier werdn dann die Larvenmassen pro step eingetragen, quasi als "Gedächnis" der Pflanze, ob ihr Schaden zugefügt wurde
    set label tau
    set label-color black
    set shape "circle"
    ;------------------------------------------------;
    set plant-dead false

    ifelse display-below-ground
      [
        set size rad-below * size-factor * 2
        set color scale-color gray  size (size-factor * 1.0) (size-factor * 7.0)
      ]
      [
        set size rad-above * size-factor * 2
        set color scale-color lime size (size-factor * 3) ( size-factor * 80)
       ; set color scale-color lime  size (size-factor * 0.1) (size-factor * 3.5)
      ]

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  larva-setting  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to larva-setting
   set switch 0               ;; 0: larvae is currently NOT moving between plants, 1: larva is moving between plants
   set plants-visited 1
   set age 0                  ;; age in days
   set distance-path 0
   set mobile? false          ;; boolean, true, when larva can switch plants (depends on age and biomass)
   set host -1                ;; number of the host plant (integer)
   set last-movement-tick 0   ;; time of last inter-plant movement 
   set biomass-larva 1        ;; biomass in mg 
   set size 15
   set label " ";biomass-larva
   set dispersal_radius dispersal_radius_larvae  * 100 ; in cm, 1 = 100 cm
   set shape "bug"
   
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   larva-wave     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to larva-wave
  let current_number_larvae 0
  while [ current_number_larvae < wave-larvae ]
  [
    set current_number_larvae current_number_larvae + 1
    let host-plant one-of plants
    if  any? plants with  [ array:item MEMORY (ticks + tau) = 0 ]  ;; zuerst immer auf die aktuell nicht-befallenen Pflanzen setzen
    [
      set host-plant one-of plants with [ array:item MEMORY (ticks + tau) = 0] ;; only one larvae per plant -> if larvae time >= 0: plant already infested
    ]
    if [plant-dead] of host-plant = true
    [
      print("i wanted to create a larva on a dead plant")
    ]
    if host-plant = nobody
    [
      print("i wanted to create a larva on a nonexisting plant")
    ]
    create-larvae 1
    [
      larva-setting
      setxy  [ xcor ] of host-plant [ ycor ] of host-plant;; noch überlegen ob ich genau 50-50 auf die beiden genotypen verteile, oder ob es sich statistisch schnell rausmittelt
      set host [ who ] of host-plant
      pen-down
      set pen-size 3
      set VISITED (list host) ; setze die aktuelle Pflanzennummer in visit-array ein
    ]
    ask host-plant
    [
      array:set MEMORY (ticks + tau) (sum [biomass-larva] of larvae-here) ; setze die Masse der Larve in Feld des Arrays mit aktuellen Zeitpunkt ein
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;              setup             ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  
  file-close-all
  if(local = true)
  [
    clear-all
  ]
  random-seed randomseed
  reset-ticks

  set simulation-length 200;; in ticks (6 ticks pro tag)

  if(local = true)
  [
    set numTaus 61
    set PLANT-TAUS array:from-list n-values (density) [1]
    let k 0 ; glaube, array fängt bei 0 an...
    while[k < density]
    [
      array:set PLANT-TAUS k random 61
      set k (k + 1)
    ]
  ]
  ;;;;;;;;;; Skales: temporal, spatial ;;;;;;;;;;;;;;;
  
  set weltweite 15
  set weltbreite 15
  resize-world 0 weltbreite 0 weltweite
  set-patch-size 2.3
  set size-factor (world-width / 800)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ask patches
  [ set pcolor white
    set nb-compete-above 0
    set nb-compete-below 0
  ]  create-plants density
  [
    plant-setting
    setxy random-xcor random-ycor
  ]
  ; ----------------- Globals (of larvae) setting ---------------------;
  set B-larva-max 10000
  set tolerance_larva defense-tolerance

  ;--------- Buffer for growth (at the beginning of time-step ---------;

  set B_before_growth array:from-list n-values density [0];

  ; ------------------- Current_defense_costs -------------------------;

  set Defense_produced_above array:from-list n-values density [0]; array with number-plants entrys, initialize with zeros biomass after growth of plant but before larva-feeding

  ;-----------  Feeding amount of larvae on this plant per time step -----------;

  set Feeding-this-step   array:from-list n-values density [0]

 ; -------------------------------------------------------------------;

 ;.............   plant globals ......................................;
  set-default-shape plants "circle"
  set B0a_max 500000 ;[mg]  ; eigentlich beide 500000 mg
  set B0b_max 500000 ;[mg]


  ;; Create and distribute larvae randomly on plants
    set current_number_tau1 0
    set current_number_tau2 0
    let current_number_larvae 0
    while [ current_number_larvae < number_larvae ]
    [
      set current_number_larvae current_number_larvae + 1
      let host-plant one-of plants
      if  any? plants with  [ array:item MEMORY (ticks + tau) = 0 ]  ;; zuerst immer auf die aktuell nicht-befallenen Pflanzen setzen
      [
        set host-plant one-of plants with [ array:item MEMORY (ticks + tau) = 0] ;; only one larvae per plant -> if larvae time >= 0: plant already infested
      ]
      if(level-GA = 3)
      [
        ifelse [tau-type] of host-plant = 1
        [
          set current_number_tau1 current_number_tau1 + 1
        ]
        [
          set current_number_tau2 current_number_tau2 + 1
        ]
      ]
      create-larvae 1
      [
        larva-setting
        setxy  [ xcor ] of host-plant [ ycor ] of host-plant;; noch überlegen ob ich genau 50-50 auf die beiden genotypen verteile, oder ob es sich statistisch schnell rausmittelt
        set host [ who ] of host-plant
        set VISITED (list host) ; setze die aktuelle Pflanzennummer in visit-array ein
        pen-down
        set pen-size 3
        ask patches in-radius dispersal_radius  [set pcolor blue]
      ]
      ask host-plant
      [
        array:set MEMORY (ticks + tau) (sum [biomass-larva] of larvae-here) ; setze die Masse der Larve in Feld des Arrays mit aktuellen Zeitpunkt ein
      ]
    ]

  ;--------------- Global variables for plots ------------------;
  set sum_damage_tau1 0
  set sum_damage_tau2 0
  set overall-mean-damage-tau1 0
  set overall-mean-damage-tau2 0
  set sum-tau1 0
  set sum-tau2 0
  set sum-residience-tau1 0
  set sum-residience-tau2 0
  set sum-number-plants-tau1 0   ;; number of plants with genotype tau1 which are currently alive
  set sum-number-plants-tau2 0   ;; number of plants with genotype tau2 which are currently alive
  set sum_damage_tau1 0          ;; damage caused by feeding larvae on all plants of genotype tau1 for the current time-step
  set sum_damage_tau2 0          ;; damage caused by feeding larvae on all plants of genotype tau2 for the current time-step
  set all_sum_damage_tau1 0       ;; sum of damage caused by feeding larvae on all plants of genotype tau1 over all time-steps
  set all_sum_damage_tau2 0      ;; sum of damage caused by feeding larvae on all plants of genotype tau2 over all time-steps
  set sum-unique-visited-pupation 0   ; number of plants visited by larvae (uniques) which reached pupation stage
  set sum-visited-pupation 0
  set sum-unique-visited 0  ; number of all plants visited by larvae (uniques per larvae)
  set sum-visited  0        ; number of  all plants visited by larvae
  set pupation-counter 0    ; number of larvae which reached pupation
  
  set all-sum-above-plants 0
  set sum-number-plants 0              ;; count of all steps in all time steps (sums up with each step)
  set sum-above-plants 0               ;; above-ground biomasse aller pflanzen (current tick)
  set sum-below-plants 0               ;; below-ground biomasse aller pflanzen (current tick)
  set sum-plants 0                     ;; gesamt-biomasse aller pflanzen (current tick)
    ; -> daraus dann: productivity -> sum-above-plants auch intereessant std and mean für ergebnisse
  set mean-above-plants 0              ;; Mean plant above-ground mass current time-step
  set mean-below-plants 0              ;; Mean plant below-ground mass current time-step
  set mean-plants 0                    ;; Mean plant mass of all plants (whole plant) current time-step
  set std-above-plants 0               ;; standard deviation of plant above-ground mass current time-step
  set std-below-plants 0               ;; standard deviation of plant below-ground mass current time-step
  set std-plants 0                     ;; standard deviation of plant mass of all plants (whole plant) current time-step
  set sum-induced-plants 0             ;; number of plants which are induced (sums up over time)
  set  switch-counter 0                ;; number of switching actions
  set defense-switch-count 0
  set defense-switch-count-now 0
  set defense_max 0.3
   
   ;---------------- for calculating mortality ---------------;
  set number-alive-plants 0  
  set number-dead-plants 0
  set sum-number-dead-plants 0   
  set larval-death-number 0            ;; number of larvas that died

  set sum-residience-time 0            ;; how long did the larvae stay on the plants
  set sum-damage-plants 0              ;; damage caused by feeding larvae on all plants for the current time-step
  set all-sum-damage-plants 0          ;; sum of damage caused by feeding larvae on all plants over all time-steps
 ; set mean-infestation-rate-plants 0   ;; mean über alle ticks  (count alle pflanzen mit raupe drauf / count alle pflanzen)
 ; set overall-mean-damage-plants 0     ;; prozentualer anteil schaden von gesamtbiomasse die insgesamt produziert wurde
  ;; what to minimize, what to maximize
  ; productivity                    ;; absolute number, maximize this or: minimize:  sum( max possible biomass) - productivity
  ; all-sum-damage-plants           ;; absolute, to be minimized
  ; overall-mean-damage-plants      ;; to be minimized, in %
  ; mean-infestation-rate-plants    ;; in %, to be minimized
   
  ;  file-open "/home/pixi/Desktop/Projekte/Time_delay/Modell/Sensitivity/Andere Tests/Robustness/movement/bilder/pflanzenwelt_x3.txt"  ;; Opening file for writing
  ;  file-print "plant.nr x.coord y.coord"
   ;  ask plants
   ;  [ 
    ;   let xround precision xcor 3
    ;   let yround precision ycor 3
    ;   file-print (word  who " "  xround  " "  yround )
    ; ]
  ;   file-close
     
    ; file-open "/home/pixi/Desktop/Projekte/Time_delay/Modell/Sensitivity/Andere Tests/Robustness/movement/bilder/Inilarvenwelt_x3.txt"  ;; Opening file for writing
    ; file-print "larva.nr x.coord y.coord"
     ask larvae
     [ 
       let xround precision xcor 3
       let yround precision ycor 3
   ;    file-print (word  who " "  xround  " "  yround )     
     ]
  ;   let tau1-pflanzen count plants with [tau-type = 1]
  ;   let tau2-pflanzen count plants with [tau-type = 2]
  ;   print (word "frequency " frequency " tau1-zahl: " tau1-pflanzen " tau2-zahl " tau2-pflanzen)
  ; let filestring (word "/home/pixi/Desktop/Projekte/Time_delay/Modell/Sensitivity/Andere Tests/Robustness/defense_delay/data/defense_development_tau_" tau1 "seed_" randomseed ".txt")
  ; let filestring2 (word "/home/pixi/Desktop/Projekte/Time_delay/Modell/Sensitivity/Andere Tests/Robustness/defense_delay/data/defense_development_pflanzen_tau_" tau1 "seed_" randomseed ".txt")
   ; file-open  filestring;; Opening file for writing
  ;  file-print "plant.nr x.coord y.coord"
;  set LARVENPFLANZEN [who] of plants with [count larvae-here >= 1]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   runtime   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go
  ask plants
  [
    let groesse [B-above] of plant who
    let def [defense-level] of plant who
    ifelse (any? larvae-here)
    [
      let gewicht [biomass-larva] of larva 2
          print (word ticks " "  who " " groesse " " def " " gewicht)
    ]
    [
      print (word ticks " "  who " " groesse " " def " " 0)
    ]
  ]
   
 ; print-growth
  ;;-------------  Refresh global variables, counters...   -----------------------;;
  ; counter (to be done every step)
  tick
  set defense-switch-count-now 0
  if not any? plants [ stop ]  
  make-updates ; update variables, counters...  
  make-plots
  ; setze counter auf null
  set sum-damage-plants 0 ; wird in consumed funktion gesetzt
  set number-dead-plants 0 ;wird in decompose gesetzt
  
  if ticks = 160
  [
;    print (word "mean-visit-pupation = " mean-visit-pupation) 
;    print (word "number-visit-unique = " number-visit-unique)
;    print (word "mean-visit-all = " mean-visit-all )
;    print (word "mean-unique-pupation = " mean-unique-pupation)
;    print (word "prod: " productivity " overall-mean-damage-plant: " overall-mean-damage-plants " mean-infestation-rate-plants: " mean-infestation-rate-plants)
    file-close
    stop
  ]

;;;;;;;;; larval wave?;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;2                                                                                                     ;;
  if larva-waves = 2 and ticks = wave-delay
  [
    larva-wave
  ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set Feeding-this-step   array:from-list n-values density [0]
  ask larvae [ set age ticks ]
  ask plants
  [
    array:set MEMORY (ticks + tau) ( sum [biomass-larva] of larvae-here )
    array:set B_before_growth who B-above
  ]
  ;; growth and death of plants
  ask plants with [plant-dead = false]
    [
      calculate-sizes-of-ZOI
    ]
    calculate-competition-indices
    ask plants with [plant-dead = false]
    [
      potential-plant-growth       ;; potential plant growth considering competition and resource scarceness
      plant-defense-production
      smallest-compartment-defines-all
      self-restriction-of-plant-growth
      allometric-growth-adjustment
    ]
  ;;; growth, movement and death of larvae
  ask larvae
  [
    larval-growth
    update-mobile
    pupation?
    larva-choose-new-host-plant
    larval_death
  ]


    ; Hier: Calculate defense level of plant, using the calculated amount of produced defense of this plant during this current time-step
  ask plants with [plant-dead = false]
  [
    ;let current_costs array:item Current_defense_costs who ; the above-ground biomass gained during this time step
    calculate-plant-defense-level array:item Defense_produced_above who
  ]
  ask plants with [plant-dead = true]
  [
    decompose
  ]

  ask plants
  [
     ifelse display-below-ground
     [set size rad-below * size-factor * 2]
     [set size rad-above * size-factor * 2]
  ]
  set steps steps + 1

end  ; of to go
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  calculate-sizes-of-ZOI  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;                                                                                                      ;;
     ;;  observer-procedure:                                                                                 ;;
     ;;                                                                                                      ;;
     ;;Calculates the current area of both, the plant's above- and belowground ZOI.
     ;;
     ;; Input Parameter: plant identity (plant p)
     ;; Returns: ZOI_p(above) and ZOI_p(below)
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    to calculate-sizes-of-ZOI

      set A_ZOI_above B-above ^ ( 3 / 4 )
      set A_ZOI_below B-below ^ ( 3 / 4 )
      set rad-above ( B-above ^ ( 3 / 8 ) ) * ( PI ^ ( -1 / 2 ) )
      set rad-below ( B-below ^ ( 3 / 8 ) ) * ( PI ^ ( -1 / 2 ) )
    end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  calculate-competition-indices  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                                      ;;
;;  observer-procedure:                                                                                 ;;
;;                                                                                                      ;;
;;  Calculates for both compartments of plant p (root and shoot) the current competition indices,       ;;
;;  C_a and C_b. C_a and C_a are defined as average of the plant's share of the available resources     ;;
;;  over all patches within the plant's ZOI (above- or belowground)                                     ;;
;;                                                                                                      ;;
;;  It distinguishes between different types of competition which can be chosen manually
;;  at the beginning of the simulation (in the interface):                                              ;;
;;  "off", "complete symmetry", "size symmetry", "allometric size asymmetry".                           ;;
;;
;;  Used local variables:
;;
;;  - nb-compete-above/nb-compete-below:
;;             index which determines, how many (and depending on chosen competition mode to            ;;
;;             which proportion) plants are sharing the same patch.                                     ;;
;;                                                                                                      ;;
;;  - number_patches_ZOI_above (or below):                                                              ;;
;;              sum of all patches within the current plant's ZOI (above or belowground)                ;;
;;
;;   Returns:
;;
;;  - C_a/C_b:                                                                                          ;;
;;           competition index of above- and belowground compartment                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to calculate-competition-indices

  ;;-------------------------- types of above-ground competition ----------------------------------;;
  ask plants
  [
      let num_patches count patches in-radius (rad-above * size-factor)
      if ( num_patches <= 0)
      [
        set plant-dead true
      ]
  ]
    if above-competition = "off"
    [
      ask plants with [plant-dead = false] [ set C_a 1]
    ]
    
    if above-competition = "complete symmetry"
    [
      ask patches [ set nb-compete-above 0 ]
      ask plants with [plant-dead = false]
      [
        ask patches in-radius (rad-above * size-factor) [ set nb-compete-above nb-compete-above + 1 ]
      ]
      ask patches with [nb-compete-above > 0]
      [
        set nb-compete-above 1 / nb-compete-above  ; the plant's share of the resources of current patch
      ]
      ask plants with [plant-dead = false]
      [
        let number_patches_ZOI_above (count patches in-radius (rad-above * size-factor) )
        let nbsh-compete-above  (sum ([nb-compete-above] of patches in-radius (rad-above * size-factor)))
        set C_a nbsh-compete-above / number_patches_ZOI_above
      ]
    ]
    
    if above-competition = "allometric symmetry"
    [
      ask patches [set nb-compete-above 0]
      ask plants with [plant-dead = false]
      [
        ask patches in-radius (rad-above * size-factor) [ set nb-compete-above nb-compete-above + [B-above ^ (3 / 4)] of myself ]
      ]
      ask patches with [nb-compete-above > 0]
      [
        set nb-compete-above 1 / nb-compete-above  ; the plant's share of the resources of current patch
      ]
      ask plants with [plant-dead = false]
      [
        let number_patches_ZOI_above (count patches in-radius (rad-above * size-factor) )
        let nbsh-compete-above  (sum ([nb-compete-above * [B-above ^ (3 / 4)] of myself] of patches in-radius (rad-above * size-factor)))
        set C_a nbsh-compete-above / number_patches_ZOI_above
      ]
    ]
    
    if above-competition = "size symmetry"
    [
      ask patches [set nb-compete-above 0]
      ask plants with [plant-dead = false]
      [
        ask patches in-radius (rad-above * size-factor) [ set nb-compete-above nb-compete-above + [B-above] of myself ]
      ]
      ask patches with [nb-compete-above > 0]
      [
        set nb-compete-above 1 / nb-compete-above
      ]
      ask plants with [plant-dead = false]
      [
        let number_patches_ZOI_above (count patches in-radius (rad-above * size-factor) )
        let nbsh-compete-above  (sum ([nb-compete-above * [B-above] of myself] of patches in-radius (rad-above * size-factor)))
        set C_a nbsh-compete-above / number_patches_ZOI_above
        
      ]
    ]
    
    if above-competition = "allometric asymmetry"
    [
      ask patches [set nb-compete-above 0]
      ask plants with [plant-dead = false]
      [
        ask patches in-radius (rad-above * size-factor) [ set nb-compete-above nb-compete-above + [B-above ^ 10] of myself ]
      ]
      ask patches with [nb-compete-above > 0]
      [
        set nb-compete-above 1 / nb-compete-above
      ]
      ask plants with [plant-dead = false]
      [
        let number_patches_ZOI_above (count patches in-radius (rad-above * size-factor) )
        let nbsh-compete-above  (sum ([nb-compete-above * [B-above ^ 10] of myself] of patches in-radius (rad-above * size-factor)))
        set C_a nbsh-compete-above / number_patches_ZOI_above
      ]
    ]
    
    if above-competition = "complete asymmetry"
    [
      ask patches [set nb-compete-above 0]
      ask plants with [plant-dead = false]
      [
        ask patches in-radius (rad-above * size-factor)
        [
          ifelse nb-compete-above = 0 [ set nb-compete-above [who] of myself ]
          [
            ifelse ( [B-above] of plant ( nb-compete-above ) ) > [B-above] of myself [ ] ;do nothing
            [
              set nb-compete-above [who] of myself ]
          ]
        ]
      ]
      ask plants with [plant-dead = false]
      [
        let number_patches_ZOI_above (count patches in-radius ( rad-above * size-factor ) )
        let nbsh-compete-above  (count patches in-radius ( rad-above * size-factor ) with [nb-compete-above = [who] of myself] )
        set C_a nbsh-compete-above / number_patches_ZOI_above
      ]
    ]
    
    ;; type of below-ground competition
    if below-competition = "off"
    [
      ask plants with [plant-dead = false] [ set C_b 1]
    ]
    
    if below-competition = "complete symmetry"
    [
      ask patches [set nb-compete-below 0]
      ask plants with [plant-dead = false]
      [
        ask patches in-radius (rad-below * size-factor)
        [
          set nb-compete-below nb-compete-below + 1
        ]
      ]
      ask patches with [nb-compete-below > 0]
      [
        set nb-compete-below 1 / nb-compete-below
      ]
      ask plants with [plant-dead = false]
      [
        let number_patches_ZOI_below (count patches in-radius (rad-below * size-factor) )
        let nbsh-compete-below  (sum ([nb-compete-below] of patches in-radius (rad-below * size-factor)))
        set C_b nbsh-compete-below / number_patches_ZOI_below
      ]
    ]
    
    if below-competition = "allometric symmetry"
    [
      ask patches [set nb-compete-below 0]
      ask plants with [plant-dead = false]
      [
        ask patches in-radius (rad-below * size-factor) [ set nb-compete-below nb-compete-below + [B-below ^ (3 / 4)] of myself ]
      ]
      ask patches with [nb-compete-below > 0]
      [
        set nb-compete-below 1 / nb-compete-below
      ]
      ask plants with [plant-dead = false]
      [
        let number_patches_ZOI_below (count patches in-radius (rad-below * size-factor) )
        let nbsh-compete-below  (sum ([nb-compete-below * [B-below ^ (3 / 4)] of myself] of patches in-radius (rad-below * size-factor)))
        set C_b nbsh-compete-below / number_patches_ZOI_below
      ]
    ]
    
    if below-competition = "size symmetry"
    [
      ask patches [set nb-compete-below 0]
      ask plants with [plant-dead = false]
      [
        ask patches in-radius (rad-below * size-factor) [ set nb-compete-below nb-compete-below + [B-below] of myself ]
      ]
      ask patches with [nb-compete-below > 0]
      [
        set nb-compete-below 1 / nb-compete-below
      ]
      ask plants with [plant-dead = false]
      [
        let number_patches_ZOI_below (count patches in-radius (rad-below * size-factor) )
        let nbsh-compete-below  (sum ([nb-compete-below * [B-below] of myself] of patches in-radius (rad-below * size-factor)))
        set C_b nbsh-compete-below / number_patches_ZOI_below
      ]
    ]
    
    if below-competition = "allometric asymmetry"
    [
      ask patches [set nb-compete-below 0]
      ask plants with [plant-dead = false]
      [
        ask patches in-radius (rad-below * size-factor) [ set nb-compete-below nb-compete-below + [B-below ^ 10] of myself ]
      ]
      ask patches with [nb-compete-below > 0]
      [
        set nb-compete-below 1 / nb-compete-below
      ]
      ask plants with [plant-dead = false]
      [
        let number_patches_ZOI_below (count patches in-radius (rad-below * size-factor) )
        let nbsh-compete-below  (sum ([nb-compete-below * [B-below ^ 10] of myself] of patches in-radius (rad-below * size-factor)))
        set C_b nbsh-compete-below / number_patches_ZOI_below
      ]
    ]
    
    if below-competition = "complete asymmetry"
    [
      ask patches [set nb-compete-below 0]
      ask plants [ ask patches in-radius (rad-below * size-factor)
        [ ifelse nb-compete-below = 0
          [ set nb-compete-below [who] of myself ]
          [ ifelse ( [B-below] of plant ( nb-compete-below ) ) > [B-below] of myself
            [ ] ;do nothing
            [ set nb-compete-below [who] of myself ] ] ] ]
      ask plants with [plant-dead = false]
      [
        let number_patches_ZOI_below (count patches in-radius ( rad-below * size-factor ) )
        let nbsh-compete-below  (count patches in-radius ( rad-below * size-factor ) with [nb-compete-below = [who] of myself] )
        set C_b nbsh-compete-below / number_patches_ZOI_below
      ]
    ]
end ; of calculate-competition-indices



    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    potential-plant-growth   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;                                                                                                  ;;
    ;; a plant (turtle) procedure                                                                       ;;
    ;;                                                                                                  ;;
    ;; calculates the potential growth of plant p at the current time. Potential growth means, that     ;;
    ;; resources available and plant-plant competition are considered, larval damage,                   ;;
    ;; defense allocation and growth plasticity are not included here.                                  ;;
    ;;                                                                                                  ;;
    ;; Variables:                                                                                       ;;
    ;;    - delta_gr_above/below:
    ;;         the gain/loss of biomass (above or belowground) for current time-step                    ;;
    ;;    - R_a / R_b:                                                                                  ;;
    ;;          resource limitation above/below                                                         ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to potential-plant-growth

  let R_a 1 - resource-limitation-above
  let R_b 1 - resource-limitation-below

  ifelse R_a <= 0 or R_b <= 0
  [
      set plant-dead true ; plant dies if no resources available
  ]
  [
    set delta_gr_above A_ZOI_above * R_a * C_a * intrinsic-growth-rate
    set delta_gr_below A_ZOI_below * R_b * C_b * intrinsic-growth-rate
  ]
end ; of potential-plant-growth





    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   plant-defense-production    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;                                                                                                      ;;
    ;; A turtle-procedure (plants):
    ;;                                                                                                      ;;
    ;; calculates the amount of defense produced for the shoot and the root compartment                     ;;
    ;; and incorporates the energy required to produce the defense compounds into the growth equations      ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to plant-defense-production

  set delta_defense_a defense-costs delta_gr_above
  set delta_defense_b defense-costs delta_gr_below

  ;; include defense into growth equations:
  set delta_gr_above delta_gr_above  - delta_defense_a
  set delta_gr_below delta_gr_below - delta_defense_b

 array:set Defense_produced_above  who delta_defense_a
end ; of plant-defense-production



;;;;;;;;;;;;;;;;;;;;;; to-report defense-costs ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                             ;;
;;A plant procedure (turtle):                                                  ;;
;;                                                                             ;;
;;  calculates the costs of a plant to allocate defenses                       ;;
;;  when defense production is currently induced, else: defense = 0            ;;
;;  defense is currently induced                                               ;;
;;  + sets plant colour "yellow" if currently induced                          ;;
;;                                                                             ;;
;;   Receives:                                                                 ;;
;,           - delta_biomass (gain in biomass)                                 ;;
;;   Returns:                                                                  ;;
;;           - defense-costs                                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report defense-costs[ delta_biomass ]

  let costs 0.0
  set color green
  if(array:item MEMORY ticks > 0)                  ;; Is the induced defense currently activated (did a larva attack in time step (t-tau)?
                                                   ;; ticks - tau (array ist um tau Schritte nach hinten -> Richtung Vergangenheit verschoben)
  [

    set color yellow                               ;; induced plants can be recognized
    set costs defense-fraction * delta_biomass
    if delta_biomass < 0
    [
      set costs 0
    ]
    if defense-level >= defense_max  ; is the maximum of defense reached? -< then stop producing defense!
    [
      set color orange  
      set costs 0
    ]
    set sum-induced-plants sum-induced-plants + 1
  ]
   report costs
end


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   smallest-compartment-defines-all   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;                                                                                                   ;;
    ;; A turtle-procedure (plants):                                                                      ;;
    ;;                                                                                                   ;;
    ;; The growth rate is restricted to the growth capacity of the smallest compartment                  ;;
    ;;
    ;; Variables:                                                                                        ;;
    ;;
    ;;    - delta_gr:                                                                                    ;;
    ;;             biomass produced this time-step for whole plant                                       ;;
    ;;    - delta_gr_above/below:                                                                        ;;
    ;;             biomass produced above/belowground (current time step)                                ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to smallest-compartment-defines-all

    ifelse (delta_gr_above < delta_gr_below)
    [
       set delta_gr  2 * delta_gr_above
    ]
    [
       set  delta_gr  2 * delta_gr_below
    ]

end  ; of smallest-compartment-defines-all



    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   self-restriction-of-plant-growth   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;                                                                                                   ;;
    ;; A turtle-procedure (plants):                                                                      ;;
    ;;                                                                                                   ;;
    ;; Calculates self-limiting growth term to ensure that the maximal biomass a plant can               ;;
    ;; maintain is not exceeded.                                                                         ;;
    ;;
    ;; Variables:                                                                                        ;;
    ;;
    ;;    - B0a_max/B0b_max:                                                                             ;;
    ;;             constant giving the maximal biomass (above- and below) a plant can attain under       ;;
    ;;             perfect conditions (no resource limitations, no competition).                         ;;
    ;;    - B_max:                                                                                       ;;
    ;;             the maximal size, the plant can attain under current conditions                       ;;
    ;;    - B:                                                                                           ;;
    ;;             the current biomass (above + belowground) of the plant                                ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to self-restriction-of-plant-growth

    let R_a 1 - resource-limitation-above
    let R_b 1 - resource-limitation-below
    set B_max B0a_max * (R_a * C_a) ^ 4 + B0b_max * (R_b * C_b) ^ 4
    ifelse delta_gr < 0
    [  ; for negative growth: set growth equal to 0
           ; no growth -> gr, gr_above, gr-below = 0
       set B B + 0
    ]
    [
       set B B + delta_gr
    ]
    ifelse ( B_max > 0) and (B_max > B)
    [
      set delta_gr_above delta_gr_above * ( 1 - (B / B_max) ^ 0.25)
      set delta_gr_below delta_gr_below * ( 1 - (B / B_max) ^ 0.25)
    ]
    [
      set delta_gr_above 0.0000000000001
      set delta_gr_below 0.0000000000001
    ]

end  ; of self-restriction-of-plant-growth



    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   allometric-growth-adjustment   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;                                                                                                   ;;
    ;; A turtle-procedure (plants):                                                                      ;;
    ;;                                                                                                   ;;
    ;;  growth plasticity:                                                                               ;;
    ;; "harmonizes" the relation of both compartments by above-and belowground growth                    ;;
    ;;                                                                                                   ;;
    ;; Variables:                                                                                        ;;
    ;;
    ;;    - B:                    total biomass of plant (root and shoot)                                ;;
    ;;                                                                                                   ;;
    ;;    - rad-below/above:      radius of ZOIs with updated biomasses                                  ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to allometric-growth-adjustment

      ;; growth, allocation and death
      ifelse delta_gr < 0
        [  ; for negative growth: set growth equal to 0
           ; no growth -> gr, gr_above, gr-below = 0
          set B B + 0
          set B-above B-above + 0
          set rad-above ( B-above ^ ( 3 / 8 ) ) * ( PI ^ ( -1 / 2 ) )
          set B-below B-below + 0
          set rad-below ( B-below ^ ( 3 / 8 ) ) * ( PI ^ ( -1 / 2 ) )

        ]
        [
           ; calculate growth of entire plant and "harmonize" the relation of both compartments by above- and belowground growth
          set B-above (B-above + (delta_gr * (delta_gr_below ^ (3 / 4)) / (delta_gr_above ^ (3 / 4) + delta_gr_below ^ (3 / 4))))
          set rad-above ( B-above ^ ( 3 / 8 ) ) * ( PI ^ ( -1 / 2 ) )

          set B-below (B-below + (delta_gr * (delta_gr_above ^ (3 / 4)) / (delta_gr_above ^ (3 / 4) + delta_gr_below ^ (3 / 4))))
          set rad-below ( B-below ^ ( 3 / 8 ) ) * ( PI ^ ( -1 / 2 ) )

          set B B-above + B-below
        ]
      
      set r-s-ratio (B-below / B-above)
      ; calculate gain in produced mass during this step
      let biomass_before array:item B_before_growth who
      let difference B-above - biomass_before 
      set above-mass-produced above-mass-produced + difference
     ; if (who = 100)[ print (word "tick " ticks " plant 100 biomass produced " difference " biomass before " biomass_before " biomass now " B-above)]
end  ; of allometric-growth-adjustment


 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;    larval-growth    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;                                                                                             ;;
 ;; A turtle-procedure (larva):
 ;;      Calculates the change in biomass of the larva. Growth depends on the abundance and     ;;
 ;;      quality, thus defense-level of the current host plant and the larva's current size.    ;;
 ;;      Growth parameters are adapted to field-work data.                                      ;;
 ;;                                                                                             ;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to larval-growth

  let possible-biomass-larva 0
  let consumed 0
  let age_nodef 0
  let age_def 0
  let defense 0
  let costs 0 ; momentan 0, könnte aber noch auf reelle Bewegungs und Stoffwechselkosten der Larven gesetzt werden.
  let biomass-before biomass-larva
;  print (word "tick = " ticks " biomass larva = " biomass-larva)
  if(biomass-before < 0)
  [
    set biomass-before 0
  ]
  ifelse switch = 0 ; does larva have currently a host plant
  [
	    ; let larva grow prop. to consumed biomass

	    let age_old_def (biomass-before / exp(-6.329)) ^ (1 / 4.661)
	    let age_old_nodef (biomass-before / exp(-8.355)) ^ (1 / 5.856)
	    set age_def age_old_def + 1 / 6
	    set age_nodef age_old_nodef + 1 / 6
    ;  print (word "tick " ticks " age_Def " (age_def * 6) " age_NoDef " (age_nodef * 6) " mass_old "biomass-before )
	    set defense [defense-level] of plant host
	    let defenseless_factor ((0.2 - [defense-level] of plant host) / 0.2 )
	    if( defenseless_factor < 0 )
	    [
	      set defenseless_factor  0.0
	    ]
	    let wt_factor (([defense-level] of plant host) / 0.2 )
	    if( wt_factor > 1 )
	    [
	      set wt_factor 1.0
	    ]
	    set possible-biomass-larva defenseless_factor * exp(-8.355) * age_nodef ^ 5.856 + wt_factor * exp(-6.329) * age_def ^ 4.661
	    ;; calculate Larval damage
	    set consumed ( possible-biomass-larva - biomass-before ) / conversion-factor
    ;  print(word "biomass larva = " biomass-before "  consumed = " consumed )
	    ifelse consumed > ([B-above] of plant host);check if plant will be entirely consumed
	    [
	      ifelse [B-above] of plant host < 0
	      [
  	    	  set consumed 0
	      ]
	      [
  	 	      set consumed [B-above] of plant host
	      ]
	      ask plant host ; in both cases the plant is dead (eaten by larva)
	      [
		        set plant-dead true
	      ]
	      ask larvae-here
	      [
		        set switch 1
	      ]
	    ]; end of consumed > biomass
	    [ ; if consumed < biomass-above of plant
	      ask plant host
		    [
  		    set B-above B-above - consumed  ;; complete growth equation of plant
  		    set B B - consumed
          if B-above < death-threshold
          [
            set plant-dead true
            ask larvae-here
            [

              set switch 1
            ]
          ]

		    ]
	    ] ; end of consumed > biomass-above of plant
    
	  ;; verschoben von außerhalb der switch=0 ifelse abfrage nach innen, da nur wenn switch=0 ein host vorhanden und deswegen host kram gemacht werden muss
	    set biomass-larva biomass-before + consumed * conversion-factor
	    set sum-damage-plants sum-damage-plants + consumed
      if (level-GA = 3)
      [
           ifelse ([ tau-type ] of plant host = 1)
           [
               set sum_damage_tau1 sum_damage_tau1 + consumed
           ]
           [ ; host = tau2
               set sum_damage_tau2  sum_damage_tau2 + consumed
           ] ; end of tau2
      ;print (word "plant number " host " larva " who " consumed " consumed " sum-damage " sum-damage-plants " tick " ticks)
      ]
	    ;; store the amount of consumed plant material of ALL Larvae currently feeding on the host plant in one array:
	    let in-array array:item Feeding-this-step host ; array of the plant: stores for each time step how much has been consumed by all larvae on this current plant (adds up)
	    array:set   Feeding-this-step  host ( consumed + in-array )
  ] ; end of switch = 0
  [
    	set consumed 0
  ] ; end of switch = -1
   let defense-word "NA"
   let masse "NA"
   if( switch = 0)
   [ 
       set defense-word ([defense-level] of plant host)
       set masse ([B-above] of plant host)
   ]
 ; file-print (word ticks " " who " " biomass-larva " " defense-word " " masse)
end  ; of larval-growth



     ;;;;;;;;;;;;;;;;;;;;;  update-mobile  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;                                                                    ;;
     ;; a turtle procedure (larvae)                                        ;;
     ;; checks, whether larval mass and age are high enough to             ;;
     ;; set the larva as "mobile" -> so that it can switch plants          ;;
     ;;                                                                    ;;
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to update-mobile
  if biomass-larva > 400 and age > 8 * 6 and switch? = true ; mass: 3. instar-mass minimum: 35 mg, age: 5 days in ticks
  [
    set mobile? true
  ]
end  ; of update-mobile


     ;;;;;;;;;;;;;;;;;;;;;;;;;  pupation?  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;                                                                    ;;
     ;; a turtle procedure (larvae)                                        ;;
     ;; checks, whether larval mass is high enough to let the larva
     ;; go to pupate (it then disappears off the simulation)               ;;
     ;;                                                                    ;;
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to pupation?

  if biomass-larva > 10000
  [
    set sum-visited-pupation sum-visited-pupation + length VISITED
    set VISITED remove-duplicates VISITED
    set sum-unique-visited-pupation sum-unique-visited-pupation + length VISITED
    set pupation-counter pupation-counter + 1
    set pupation-age-sum  pupation-age-sum + ticks 
    set sum-unique-visited sum-unique-visited  + length VISITED; number of all plants visited by larvae (uniques per larvae)
    set sum-visited sum-visited + plants-visited 
    
    die ; larve verpuppt sich -> richtet somit auf Pflanzen keinen Schaden mehr an...
        ; print (word "Larve " who " hat sich verpuppt")
  ]
end  ; of pupation?




 ;;;;;;;;;;;;;;;;;;;;;;;;;;;    larva-choose-new-host-plant   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;                                                                                               ;;
 ;; A turtle-procedure (larva):
 ;;    All mobile larvae check if they leave the host plant (if defense-level > tolerance_larva)  ;;
 ;;    Elsewise the larva stays on the plant.                                                     ;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to larva-choose-new-host-plant
    ; see whether plant is "unpalatable" for larva (too much defense)
    let costs 0
    ifelse ( switch = 0 )
    [

      if ( [defense-level] of plant host > tolerance_larva ) and ( mobile?  = true) and (last-movement-tick + 6 < ticks)
      [
        set switch 1
        set defense-switch-count defense-switch-count + 1
        set defense-switch-count-now defense-switch-count-now + 1
      ]

    ] ; end of section for larvae with host plant at the beginning of the tick
    [
      set biomass-larva biomass-larva - costs; hier kommen eventuell noch Kosten für Aktivitäten der Larve hinzu
      switch-plants ; wenn die Raupe keinen host hatte
   ]
end  ;; of larva-choose-new-host-plant


     ;;;;;;;;;;;;;;;;;;;;;;   switch-plants   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;                                                                               ;;
     ;; a turtle procedure (larvae)                                                   ;;
     ;; The larva chooses  the host plant to visit next (acc. to dispersal radius).   ;;
     ;; For the moment: no costs for switching, later higher death prob.              ;;
     ;; duration of switching: 1 time step (4 hours)                                  ;;
     ;;                                                                               ;;
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to switch-plants
  set switch 0  ; switchen erledigt
  ifelse mobile? = true  ; nur mobile Larven wechseln Pflanzen
  [
    let new-host host
    if movement-modus = 1
    [
      ifelse any? plants in-radius dispersal_radius with [ who != new-host]
      [
      ;  print "switch"
        ;print(word "plants are in disp radius")
        while [ host = new-host ]
        [
          ; 1) erfasse alle Pflanzen innerhalb Raupenradius
          ; 2) Berechne die Distanzen zur Raupe
          ; 3) Berechne I_max
          ; 4) Berechne Intervallabschnitt pro Pflanze und tue diese als "value" in die Table, als "key" dann die Pflanzen nummer (who)
          ; 5) ziehe Zufallszahl (float) rand float Int_max und prüfe, in welches Intervall sie fällt -> dies ist die neue host plant...!
          
          ; 1: erfasse alle Pflanzen in Raupen-dispersal-radius und 2) berechne ihre Distanzen zur Raupe:
          
          let distance_all 0       ; sum of all distances
          let distance_plant 0     ; distance of the current plant from larva in center
          let distance_quotient 0  ; the length of the interval for current plant
          let interval_max 0       ; length of the whole interval
          
                                   ; calculate the sum of all distances of all plants in dispersal_radius

            ask plants in-radius dispersal_radius with [plant-dead = false]
            [
              set distance_plant distancexy [xcor] of myself [ycor] of myself
              set distance_all  distance_all + exp distance_plant 
            ]
          ; now calculate
          let interval table:make

            ask plants in-radius dispersal_radius with [plant-dead = false]
            [
              if ( who != [host] of myself )
              [
                set distance_plant distancexy [xcor] of myself [ycor] of myself
                ; print (word "plant nr.: " who  ", host number = " [host] of myself ", biomass of plant in dispersal-radius = " B-above  ", plant-dead = " plant-dead ", distance = " distance_plant)
                ; self = gerade aufgerufene Pflanze
                ; myself = die Raupe, die die ganzen "ask-Plants" aufgerufen hat
                ; calculate distance between larva and plant in dispersal-radius: works :)
                if(distance_plant > 0)
                [
                  ; set distance_quotient distance_quotient +  distance_all / (exp distance_plant)
                  set distance_quotient distance_quotient +  distance_all / (exp distance_plant)
                  
                  ; make table with keys = plant numbers and values = distances to larva (center)
                  table:put interval who distance_quotient
                ]
              ]
          ]
          set interval_max distance_quotient
          
          ; interval is set, now draw a random float and look in which section it can be sorted (next host plant)...
          let zufall random-float interval_max
          let schluessel table:keys interval
          let i 0
          let interval_length 0
          while  [zufall > interval_length]  ;go through list (from the start to the end) unless the random-float is smaller than intervall-border
                                             ; -> the corresponding key is the "who" of the new host plant
          [
            let llave item i schluessel
            ;print (word "Key = " llave)
            set interval_length table:get interval llave
            set new-host llave
            set i  ( i + 1 )
          ]
          ;set new-host [who] of one-of plants
        ]
      ;  file-print(word who " " precision xcor 3 " "precision ycor 3 " " precision [ xcor ] of plant new-host 3 " " precision [ ycor ] of plant new-host 3)
         set host new-host
         set distance-path distancexy [xcor] of plant host [ycor] of plant host
        ; file-print (word who " " distance-path)
         set last-movement-tick ticks
         let host-plant plant host
         setxy [ xcor ] of host-plant [ ycor ] of host-plant
         ask host-plant [array:set MEMORY (ticks + tau) (sum [biomass-larva] of larvae-here)] ;; setze die Masse der Larve in Feld des Arrays mit aktuellen Zeitpunkt ein
      ]
      [
        ;else
        ; print(word "larva " who " just died")
        die
      ]
    ]; end of movement-modus "distance"
   if movement-modus = 2
   [
        let host-plant one-of plants
        set host [who] of host-plant
        set distance-path distancexy [xcor] of plant host [ycor] of plant host
     ;   file-print(word who " " precision xcor 3 " "precision ycor 3 " " precision [ xcor ] of plant host 3 " " precision [ ycor ] of plant host 3)
        set last-movement-tick ticks
        setxy [ xcor ] of host-plant [ ycor ] of host-plant
        ask host-plant [array:set MEMORY (ticks + tau) (sum [biomass-larva] of larvae-here)] ;; setze die Masse der Larve in Feld des Arrays mit aktuellen Zeitpunkt ein
    ] ; end of random distribution
   set plants-visited plants-visited + 1
   set VISITED lput host VISITED
  ]
  [  ; not mobile
  if plant host = nobody ;; if plant death starts the switching by decompose for a nonmobile larva this gets triggered
  [
    die
  ]
  ]
end  ; of switch-plants



     ;;;;;;;;;;;;;;;;;;;;;  larval_death  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;                                                                    ;;
     ;; a turtle procedure (larvae)                                        ;;
     ;; calculates the current probability of the larva to die during      ;;
     ;; the current time step (this depends on the current plant's defense ;;
     ;; level, the larval biomass and is highest if the larva is currently ;;
     ;; commuting                                                          ;;
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to larval_death
  let death_prob 0
  let coeff 0
  let death_dice random-float 1.0 ;; neu eingeführt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; new
  ifelse switch = 0  ; larva on plant
  [
     ifelse mobile?   ; larva >= 3rd instar
    [
      set coeff ( death_coeff + 1.5 * [defense-level] of plant host - 0.1 ) / 6 ; zwischen 0.0 und 1.0
    ]
    [  ; larva < 3rd instar
      set coeff ( death_coeff + 1.5 * [defense-level] of plant host) / 6
    ]
  ]
  [ ; if not on plant
    set coeff 1 / 6 * ( distance-path * 1.5 / dispersal_radius  + death_coeff )
   ; set coeff 1 / 6   + death_coeff
  ]
  if coeff > 1.0
  [
      set coeff  1.0
  ]
  if coeff < 0.0
  [
      set coeff  0.0
  ]
  set death_prob  ( coeff / (1 + log biomass-larva exp 1 ) )
  if switch = 1
  [
    ;print (word "larva number " who " death_prob " death_prob " distance_penalty " coeff " distance " distance-path)
  ]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if death_dice <= death_prob
  [
   set larval-death-number larval-death-number + 1
    set VISITED remove-duplicates VISITED
    set  sum-unique-visited sum-unique-visited  + length VISITED; number of all plants visited by larvae (uniques per larvae)
    set sum-visited sum-visited + plants-visited 
   die
  ]
end  ; of larval_death



;;;;;;;;;;;;;;;;;;;;;; calculate-plant-defense-level ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                             ;;
;; A plant procedure (turtle):
;; calculates the new defense level of the plant                               ;;
;; for the current time-step                                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to calculate-plant-defense-level [ defense-gain-above ];; VORSICHT: HIER NOCH EVTL UMÄNDERN -> Momentan für gesamte Pflanze dasselbe Defense-Level

  let biomass_before array:item B_before_growth who ;only above-ground: array of the plant's above biomass (state of the beginning of the time-step)
  let defense-level-before defense-level
  let defense_before defense-level * biomass_before
  let eaten 0
  ifelse any? larvae-here
  [
    set eaten array:item Feeding-this-step who ; biomass removed by all caterpillars feeding on this plant during this time step
    set damage-sum damage-sum + eaten
    set defense-level ( defense-level *  biomass_before + defense-gain-above - eaten * defense-level ) / B-above ; aktualisiere defense level
  ]
  [
    set defense-level ((defense-level-before * biomass_before + defense-gain-above ) / B-above ); ansonsten kein fraßschaden der Raupe -> keine produzierte Defense wird "weggenommen"
  ]
end  ; of calculate-plant-defense-level



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;  decomposition  ;;;;;;;;;;
;;   A turtle (plant) procedure  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to decompose
  let host-number who
  ask larvae with [host = host-number]
  [
    set switch 1
  ]
  set sum-number-dead-plants sum-number-dead-plants + 1
  die

  ifelse display-below-ground
    [ set size rad-below * size-factor * 2 ]
    [ set size rad-above * size-factor * 2 ]

end ; of decomposition





;;;;;;;;;;;;;;;;;;;;;;;;;  make-updates  ;;;;;;;;;;;;;;;;;;;;;;;
;;
;; prints out desired variables in the given file
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to make-updates
 if (level-GA = 3)
 [
    set sum-tau1 sum [B] of plants with [tau-type = 1] + sum-tau1
    set sum-tau2 sum [B] of plants with [tau-type = 2] + sum-tau2 
    set sum-above-tau1 sum [B-above] of plants with [tau-type = 1] + sum-above-tau1
    set sum-above-tau2 sum [B-above] of plants with [tau-type = 2] + sum-above-tau2
 ;   set  overall-mean-damage-tau1 (sum_damage_tau1  / sum-above-tau1)  ;; gesamtsumme schaden/ gesamtsumme biomasse (für tau 1)
 ;   set  overall-mean-damage-tau2 (sum_damage_tau2 / sum-above-tau2)   ;; gesamtsumme schaden/ gesamtsumme biomasse (für tau 2)
 ]
  ; beachte hier die gestorbenen Pflanzen -> die haben auch eine Masse = 0, die zum Mean beiträgt!
  set number-alive-plants count plants 
  set sum-number-plants sum-number-plants + number-alive-plants ;; count of all steps in all time steps (sums up with each step)
  update-sum-residience-time 
  ; number-dead-plants wird in decompose gesetzt
  set sum-above-plants sum [B-above] of plants          ;; above-ground biomasse aller pflanzen (current tick)
  set sum-below-plants sum [B-below] of plants          ;; below-ground biomasse aller pflanzen (current tick)
  set sum-plants sum [B] of plants     
   
  set all-sum-above-plants all-sum-above-plants + sum-above-plants
  set all-sum-damage-plants all-sum-damage-plants + sum-damage-plants         ;; sum of damage caused by feeding larvae on all plants over all time-steps, given in larval_growth
 ; print (word " all-sum-above " all-sum-above-plants " summe schaden " all-sum-damage-plants " tick " ticks)
;  print "-----------------------------------------------------------------------------------"
   
    ; -> daraus dann: productivity -> sum-above-plants auch intereessant std and mean für ergebnisse
  set mean-above-plants mean [B-above] of plants        ;; Mean plant above-ground mass current time-step
  set mean-below-plants mean [B-below] of plants        ;; Mean plant below-ground mass current time-step
  set mean-plants mean [B] of plants              ;; Mean plant mass of all plants (whole plant) current time-step
  if(number-alive-plants >= 2)
  [
      set std-above-plants standard-deviation [B-above] of plants         ;; standard deviation of plant above-ground mass current time-step
      set std-below-plants standard-deviation [B-below] of plants          ;; standard deviation of plant below-ground mass current time-step
      set std-plants standard-deviation [B] of plants                ;; standard deviation of plant mass of all plants (whole plant) current time-step
  ]
  ; larval-death-number  wird in larval_death gesetzt      
 

  let mean-biomass-larvae 0
  
  if any? larvae
  [
   set mean-biomass-larvae mean [biomass-larva] of larvae
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  make-plots ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; an observer procedure
;; updates all plots seen in the "interface"-Tab
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to make-plots

 ; auto-plot-on
; if(ticks mod 6 = 0)[ print (word "tick " ticks " plant " plant-number " ,  biomass-above-ground " [B-above] of plant plant-number " biomass-plant " [B] of plant plant-number) ]
  set-current-plot "Larva_dead"
  set-plot-pen-mode 0
  set-current-plot-pen "number-dead"
  plotxy (ticks + 1) larval-death-number  ;sums up: number of larvae which really died (and did not go to pupate)

  set-current-plot "Above-ground-sizes"
  set-current-plot-pen "above"
  histogram [B-above] of plants
  set-histogram-num-bars 20

  set-current-plot "mean infestation rate plants"
  set-current-plot-pen "all"
    set-plot-pen-mode 0
  plotxy (ticks + 1) mean-infestation-rate-plants

  
  ;; Mean residence time of larvae
    set-current-plot "Mean residence time" ; in %
    if count plants > 0
    [
      set-current-plot-pen "residience"
      let mean-residence-ticks sum-residience-time / sum-number-plants * 100
      plotxy (ticks + 1) mean-residence-ticks
    ] 

  ;; biomass
  set-current-plot "Mean biomass through time"
  if count plants > 0
  [
    set-current-plot-pen "Mean"
    plotxy (ticks + 1) mean [B] of plants
    set-current-plot-pen "Mean-above"
    plotxy (ticks + 1) mean [B-above] of plants
    set-current-plot-pen "Mean-below"
    plotxy (ticks + 1) mean [B-below] of plants
  ]

  set-current-plot "Total biomass through time"
  if count plants > 0
  [
    set-current-plot-pen "Total"
    plotxy (ticks + 1) sum [B] of plants
    set-current-plot-pen "Total-above"
    plotxy (ticks + 1) sum [B-above] of plants
    set-current-plot-pen "Total-below"
    plotxy (ticks + 1) sum [B-below] of plants
    set-current-plot-pen "Total-prod" 
    plotxy (ticks + 1)  sum [above-mass-produced] of plants 
    
  ]
      if any? larvae
    [
      set-current-plot "mean-biomass-larvae"
      set-current-plot-pen "mass"
      set-plot-pen-mode 0
      plotxy (ticks + 1) mean [biomass-larva] of larvae
      

      set-current-plot "biomass-larvae"
      set-histogram-num-bars 20
      histogram [biomass-larva] of larvae
    ]
  
    set-current-plot "tau-distribution"
   ; set-histogram-num-bars ( tau-max - tau-min )
    histogram [tau] of plants

    set-current-plot "mean-residience-time (alive)"
    set-histogram-num-bars 20 ; in steps of 5%
    histogram [ mean-residence-time ] of plants

  ;; Mean-damage
  set-current-plot "Sum of damage"
  ; mean damage = summe aller Schäden, die an Pflanze angefallen sind/
  set-current-plot-pen "damage"
  set-plot-pen-mode 0
  plotxy (ticks + 1) all-sum-damage-plants

  ;; Mean-damage
  set-current-plot "Mean-damage"
  ; mean damage = summe aller Schäden, die an Pflanze angefallen sind/
  set-current-plot-pen "Tau1"
  set-plot-pen-mode 0
  plotxy (ticks + 1)  overall-mean-damage-plants

  ;; Mean-damage
  if any? plants with [ who = plant-number] 
  [
    set-current-plot "defense-plot-single-plant"
    ; mean damage = summe aller Schäden, die an Pflanze angefallen sind/
    set-current-plot-pen "mass-above"
    set-plot-pen-mode 0
    plotxy (ticks + 1) [B-above] of plant plant-number 
    set-current-plot-pen "biomass"
    set-plot-pen-mode 0
    plotxy (ticks + 1) [B] of plant plant-number 
    set-current-plot-pen "defense"
    set-plot-pen-mode 0
    plotxy (ticks + 1) ([B-above] of plant plant-number * [defense-level] of plant plant-number)
    set-current-plot-pen "damage"
    set-plot-pen-mode 0
     let damage array:item Feeding-this-step plant-number
    plotxy (ticks + 1) (damage)
  ]

end  ; of make-plots

;;-----------------------------------------------------------------------------;;
to-report factor [n]  ;; return the smallest integer divider of n larger than its square root (translated directly from Weiner's code)
  let root floor(sqrt(n))
  while [(n / root) < root] [ set root root + 1 ]
  report root
end

to-report dead-larvae
 report larval-death-number
end

to-report number-dead
 report sum-number-dead-plants
end

to-report productivity
 let prod sum-above-plants    
 report prod
end

to-report overall_damage  ;; absolute value, sum of all damage any plant has taken over all time steps
 report all-sum-damage-plants
end

to-report BIOMASSVECTOR ;; vector of all biomasses at the end of simulation
 
 let TAU-BIOMASS array:from-list n-values (numTaus) [0]
 ask plants
 [
   array:set TAU-BIOMASS tau (array:item TAU-BIOMASS tau + B-above) 
 ]
 let pia-list array:to-list TAU-BIOMASS
 report pia-list
end

to-report overall-mean-damage-plants ; in %
 let damage  ( sum [damage-sum] of plants  / sum [above-mass-produced] of plants ) * 100  ;; prozentualer anteil schaden über gesamtbiomasse produziert    
 report damage
end


to print-growth
  ask plants
  [
        let infested 0
    if (any? larvae-here)
    [
      set infested 1
    ]
    let induced 0
    if(color != green)
    [
        set induced 1
    ]
    let damage array:item Feeding-this-step who
    let defense defense-level
    file-print(word ticks " " who " " B-above " " B-below " " infested " " induced " " defense " " damage)
  ]
end ; of decomposition

 

to-report mean-infestation-rate-plants  ;in %
   let mean-infestation sum-residience-time / sum-number-plants * 100        
 report mean-infestation
end

to-report mean-induced-rate-plants  ;in %
   let mean-induced sum-induced-plants / sum-number-plants * 100        
 report mean-induced
end

to-report mean-unique-pupation  ;how many plants did larvae visit
  let anzahl pupation-counter
  if(anzahl = 0)
  [
    set anzahl 1
  ]
 report sum-unique-visited-pupation / anzahl
end

to-report mean-visit-pupation  ;how many plants did larvae visit
    let anzahl pupation-counter
  if(anzahl = 0)
  [
    set anzahl 1
  ]
   report sum-visited-pupation / anzahl
end

  
to-report pupation-age
 let anzahl pupation-counter   
  if(anzahl = 0)
  [
    set anzahl 1
  ]
 let test pupation-age-sum / anzahl
 report test
end
  

to-report number-visit-unique  ;how many plants did larvae visit
 report sum-unique-visited / number_larvae
end

to-report mean-visit-all  ;how many plants did larvae visit
 report sum-visited / number_larvae
end

to-report mean-defense-switches  ;how many plants did larvae visit
 report defense-switch-count / number_larvae
end




;;;;;;;;;;;;;;;;;;;;;;;update-sum-residence_time  ;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; an observer procedure
;; calculate (for each tick) the sum of the ticks
;; in which plants are occupied by larvae. Sums up over ticks
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to update-sum-residience-time
  ask plants 
    [
      if any? larvae-here
      [
        set sum-residience-time sum-residience-time + 1
      ]
    ]
; needs a counter for all ticks*plants of whole simulation to have the TRUE mean of residience time
end

     ;;;;;;;;;;;;;;;;;;;  update mean-residence-time  ;;;;;;;;;;;;;;;;;;;;;;;;
     ;;                                                                     ;;
     ;; Reporter for a single plant                                         ;;
     ;; Calculates and returns the number of ticks when larvae occupied     ;;
     ;; the plant. [in %]                                                   ;;
     ;;                                                                     ;;
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report  mean-residence-time ;[plant-number]  ; for one plant, in %
;  ask plant plant-number
 ; [
    let laenge ticks
    let liste array:to-list  MEMORY        ; Listen lassen sich für diesen Zweck leichter bearbeiten... -> wandle array in Liste um
                                           ; filter the nonzero values from the list
    let nonzero_MEMORY filter [? > 0] liste
    let number_ticks length nonzero_MEMORY ; number of ticks a plant has been visited by larvae 
                                           ; not the *true* mean of residience time (forgets deead plants) however still useful
  let residience number_ticks / laenge * 100
  report residience
end
@#$#@#$#@
GRAPHICS-WINDOW
1325
10
1570
73
-1
-1
2.3
1
10
1
1
1
0
1
1
1
0
13
0
13
1
1
1
ticks
30.0

BUTTON
327
385
407
430
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
327
335
407
380
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
410
70
710
255
Sum of damage
Time
Damage
0.0
180.0
0.0
20000.0
true
true
"" ""
PENS
"damage" 100.0 0 -13791810 true "" ""

PLOT
1010
440
1310
625
mean infestation rate plants
time
%
0.0
180.0
0.0
100.0
true
true
"" ""
PENS
"all" 1.0 0 -13791810 true "" ""

BUTTON
327
435
407
480
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
410
255
710
440
Mean biomass through time
time
Biomass
0.0
30.0
0.0
100.0
true
true
"" ""
PENS
"Mean" 1.0 0 -2674135 true "" ""
"Mean-above" 1.0 0 -10899396 true "" ""
"Mean-below" 1.0 0 -16777216 true "" ""

SWITCH
10
10
210
43
display-below-ground
display-below-ground
1
1
-1000

PLOT
710
255
1010
440
Larva_dead
time
Number
0.0
180.0
0.0
200.0
true
true
"" ""
PENS
"number-dead" 100.0 1 -16777216 true "" ""

PLOT
1010
70
1310
255
Above-ground-sizes
Size Classes
Frequency
0.0
500000.0
0.0
20.0
true
true
"" ""
PENS
"above" 10.0 1 -16777216 true "" ""

CHOOSER
15
335
261
380
above-competition
above-competition
"off" "complete symmetry" "allometric symmetry" "size symmetry" "allometric asymmetry" "complete asymmetry"
5

CHOOSER
15
380
261
425
below-competition
below-competition
"off" "complete symmetry" "allometric symmetry" "size symmetry" "allometric asymmetry" "complete asymmetry"
1

PLOT
710
70
1010
255
Total biomass through time
time
Biomass
0.0
180.0
0.0
500000.0
true
true
"" ""
PENS
"Total" 1.0 0 -2674135 true "" ""
"Total-above" 1.0 0 -10899396 true "" ""
"Total-below" 1.0 0 -16777216 true "" ""
"Total-prod" 1.0 0 -13791810 true "" ""

SLIDER
15
459
260
492
resource-limitation-above
resource-limitation-above
0
0.99
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
15
425
260
458
resource-limitation-below
resource-limitation-below
0
0.99
0.7
0.05
1
NIL
HORIZONTAL

PLOT
710
440
1010
625
mean-residience-time (alive)
time
residence time
0.0
100.0
0.0
1.0
true
true
"" ""
PENS
"residience" 1.0 1 -16777216 true "" ""

PLOT
410
440
710
625
Mean-damage
time
Mean damage  %
80.0
160.0
0.0
0.8
true
true
"" ""
PENS
"Tau1" 1.0 2 -13791810 true "" ""

MONITOR
980
10
1095
59
Population Size
count plants
0
1
12

INPUTBOX
225
12
390
72
randomseed
15
1
0
Number

SLIDER
15
210
185
243
tau-median
tau-median
0
200
20
1
1
NIL
HORIZONTAL

SLIDER
14
249
184
282
tau-range
tau-range
0
48
10
1
1
NIL
HORIZONTAL

CHOOSER
10
800
263
845
switch?
switch?
true false
0

PLOT
1010
255
1310
440
tau-distribution
tau-values
count
0.0
210.0
0.0
100.0
true
true
"" ""
PENS
"infest" 1.0 1 -16777216 true "" ""

SLIDER
11
848
265
881
dispersal_radius_larvae
dispersal_radius_larvae
0
4
0.7
0.01
1
NIL
HORIZONTAL

SLIDER
209
128
409
161
initial_defense_level
initial_defense_level
0
0.24
0
0.001
1
NIL
HORIZONTAL

MONITOR
1110
10
1210
59
NIL
count larvae
0
1
12

CHOOSER
215
620
402
665
larva-waves
larva-waves
1 2 "continuous"
0

CHOOSER
300
715
395
760
wave-delay
wave-delay
6 12 18 24 30 36 42 48 54 60 66 72 78 84 90 96 102 108 114 120
0

SLIDER
209
163
409
196
defense_fraction_all
defense_fraction_all
0
0.7
0.3
0.05
1
NIL
HORIZONTAL

SLIDER
14
620
202
653
number_larvae
number_larvae
0
1000
1
1
1
NIL
HORIZONTAL

SLIDER
14
684
201
717
conversion-factor
conversion-factor
0
1
0.18
0.01
1
NIL
HORIZONTAL

SLIDER
14
652
202
685
death_coeff
death_coeff
0
1
0.25
0.01
1
NIL
HORIZONTAL

TEXTBOX
115
565
282
585
Larvae-variables
16
0.0
0

TEXTBOX
52
307
219
327
Patches
16
0.0
1

TEXTBOX
266
596
382
616
distribution
14
0.0
1

TEXTBOX
77
596
149
616
basics
14
0.0
1

TEXTBOX
59
779
226
799
movement
14
0.0
1

TEXTBOX
280
100
356
120
Plants
16
0.0
1

CHOOSER
220
205
404
250
density
density
1 2 3 100 200 400 600
1

SLIDER
219
254
404
287
intrinsic-growth-rate
intrinsic-growth-rate
0
1
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
215
672
400
705
wave-larvae
wave-larvae
0
400
0
1
1
NIL
HORIZONTAL

PLOT
1010
630
1310
835
Mean residence time
time
mean
0.0
180.0
0.0
10.0
true
false
"" ""
PENS
"residience" 1.0 0 -16777216 true "" ""

PLOT
410
630
705
835
biomass-larvae
biomass classes
abundance
0.0
10000.0
0.0
10.0
true
false
"" ""
PENS
"biomass" 1.0 1 -16777216 true "" ""

PLOT
715
630
1005
835
mean-biomass-larvae
ticks
mass
0.0
180.0
0.0
10000.0
true
false
"" ""
PENS
"mass" 1.0 0 -16777216 true "" ""

MONITOR
1690
745
1797
794
defense-level
[defense-level] of plant plant-number
4
1
12

SLIDER
1670
685
1842
718
plant-number
plant-number
0
400
1
1
1
NIL
HORIZONTAL

MONITOR
1700
625
1757
670
larvae?
any? larvae with [host = plant-number]
17
1
11

MONITOR
1775
625
1832
670
tau
[tau] of plant plant-number
17
1
11

PLOT
1315
635
1650
840
defense-plot-single-plant
time
mass
0.0
180.0
0.0
80000.0
true
true
"" ""
PENS
"mass-above" 1.0 0 -16777216 true "" ""
"biomass" 1.0 0 -14439633 true "" ""
"defense" 1.0 0 -2674135 true "" ""
"damage" 1.0 0 -7500403 true "" ""

TEXTBOX
35
95
185
113
Genetic Algorithm
12
0.0
1

CHOOSER
10
125
102
170
level-GA
level-GA
1 2 3
2

TEXTBOX
110
126
260
167
1 = individual\n2 = population\n3 = tau1/tau2
10
0.0
1

TEXTBOX
50
190
200
220
if population:
10
0.0
1

CHOOSER
15
45
153
90
local
local
true false
0

MONITOR
1695
805
1782
850
dead plants
number_dead
17
1
11

SLIDER
220
290
405
323
death-threshold
death-threshold
0
100000
10000
1000
1
NIL
HORIZONTAL

CHOOSER
275
790
400
835
movement-modus
movement-modus
1 2
0

SLIDER
15
720
202
753
defense-tolerance
defense-tolerance
0
1
0.24
0.01
1
NIL
HORIZONTAL

TEXTBOX
285
840
435
885
1 = distance\n2 = random
12
0.0
1

SLIDER
455
30
565
63
tau1
tau1
0
100
30
1
1
NIL
HORIZONTAL

SLIDER
570
30
675
63
tau2
tau2
0
100
0
1
1
NIL
HORIZONTAL

SLIDER
695
30
825
63
frequency
frequency
0
100
100
1
1
NIL
HORIZONTAL

TEXTBOX
700
10
850
28
percentage of tau1
12
0.0
1

@#$#@#$#@
## COPYRIGHT AND LICENSE AND WHATEVER...

Copyright 2012
      Uri Wilensky.

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, US

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

: ) : ( : ) : ( : ) : ( : ) : ( :

Copyright Two-layer model: 2009-2012 Yue Lin. yue.lin.tud@gmail.com
Copyright Time-delay model (

To reference this model in academic publications, we ask you to include these citations for the model itself and for the NetLogo software:

- Lin Y, Huth F, Berger U, Grimm V (2013). The role of belowground competition and plastic biomass allocation in altering plant mass-density relationships. Oikos, xx:xxx-xxx

- Wilensky, U (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

To get a full version pi model with R-extension for statistical analysis, please contact Yue Lin.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Movement_stats" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>count larvae = 0</exitCondition>
    <metric>mean ([defense-level] of plants)</metric>
    <enumeratedValueSet variable="display-below-ground">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="randomseed" first="1" step="1" last="25"/>
    <enumeratedValueSet variable="switch?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-threshold">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defense_fraction_all">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau-median">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level-GA">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_defense_level">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intrinsic-growth-rate">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_larvae">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defense-tolerance">
      <value value="0.24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conversion-factor">
      <value value="0.21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death_coeff">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-modus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dispersal_radius_larvae">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="larva-waves">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="HelloWorld" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 200</exitCondition>
    <metric>mass-tau1</metric>
    <metric>mass-tau2</metric>
    <enumeratedValueSet variable="display-below-ground">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau2">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decomposition-period-below">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="threshold-of-death">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decomposition-period-above">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="larva-waves">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wave-delay">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="randomseed">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Switching_stats" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="160"/>
    <metric>mean [defense-level] of plants</metric>
    <metric>mean-visit-pupation</metric>
    <metric>mean-unique-pupation</metric>
    <metric>number-visit-unique</metric>
    <metric>mean-visit-all</metric>
    <metric>pupation-counter</metric>
    <metric>pupation-age-sum</metric>
    <metric>mean-defense-switches</metric>
    <metric>mean-pupation-defense-switches</metric>
    <enumeratedValueSet variable="display-below-ground">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="above-competition">
      <value value="&quot;complete asymmetry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level-GA">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defense-tolerance">
      <value value="0.24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resource-limitation-above">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intrinsic-growth-rate">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="local">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wave-delay">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_larvae">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wave-larvae">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plant-number">
      <value value="242"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dispersal_radius_larvae">
      <value value="0.7"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial_defense_level" first="0" step="0.1" last="0.2"/>
    <enumeratedValueSet variable="below-competition">
      <value value="&quot;complete symmetry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conversion-factor">
      <value value="0.21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death_coeff">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defense_fraction_all">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-modus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-threshold">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="larva-waves">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resource-limitation-below">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="randomseed" first="1" step="1" last="100"/>
    <enumeratedValueSet variable="tau-median">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="switch?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="local">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="randomseed" first="11" step="1" last="50"/>
    <enumeratedValueSet variable="below-competition">
      <value value="&quot;complete symmetry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wave-delay">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death_coeff">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau-median">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wave-larvae">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-modus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defense_fraction_all">
      <value value="0.35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_larvae">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level-GA">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-threshold">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="above-competition">
      <value value="&quot;complete asymmetry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau-range">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="larva-waves">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defense-tolerance">
      <value value="0.24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dispersal_radius_larvae">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resource-limitation-below">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resource-limitation-above">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-below-ground">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intrinsic-growth-rate">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_defense_level">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conversion-factor">
      <value value="0.21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plant-number">
      <value value="242"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="movement_random_distance" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="160"/>
    <metric>productivity</metric>
    <metric>number-dead</metric>
    <metric>dead-larvae</metric>
    <metric>mean [defense-level] of plants</metric>
    <enumeratedValueSet variable="display-below-ground">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="above-competition">
      <value value="&quot;complete asymmetry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level-GA">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defense-tolerance">
      <value value="0.24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resource-limitation-above">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intrinsic-growth-rate">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="local">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wave-delay">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_larvae">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wave-larvae">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plant-number">
      <value value="242"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dispersal_radius_larvae">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_defense_level">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="below-competition">
      <value value="&quot;complete symmetry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conversion-factor">
      <value value="0.21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death_coeff">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defense_fraction_all">
      <value value="0.3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="movement-modus" first="1" step="1" last="2"/>
    <enumeratedValueSet variable="death-threshold">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="larva-waves">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resource-limitation-below">
      <value value="0.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="randomseed" first="1" step="1" last="100"/>
    <enumeratedValueSet variable="tau-median">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Contour_plot_single" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>count larvae = 0</exitCondition>
    <metric>sum-tau1</metric>
    <metric>sum-tau2</metric>
    <enumeratedValueSet variable="display-below-ground">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="tau1" first="0" step="6" last="30"/>
    <steppedValueSet variable="tau2" first="0" step="6" last="30"/>
    <enumeratedValueSet variable="decomposition-period-below">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_cohort">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="randomseed">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="threshold-of-death">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decomposition-period-above">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Contour_plot_neu" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean [B] of plants with [tau-type = 1]</metric>
    <metric>mean [B] of plants with [tau-type = 2]</metric>
    <metric>mean [B-above] of plants with [tau-type = 1]</metric>
    <metric>mean [B-above] of plants with [tau-type = 2]</metric>
    <metric>sum-above-tau1</metric>
    <metric>sum-above-tau2</metric>
    <metric>sum-tau1</metric>
    <metric>sum-tau2</metric>
    <metric>overall-mean-damage-tau1</metric>
    <metric>overall-mean-damage-tau2</metric>
    <metric>sum_damage_tau1</metric>
    <metric>sum_damage_tau2</metric>
    <enumeratedValueSet variable="wave-larvae">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau-median">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conversion-factor">
      <value value="0.19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="movement-modus">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="local">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death_coeff">
      <value value="0.25"/>
    </enumeratedValueSet>
    <steppedValueSet variable="tau1" first="0" step="3" last="60"/>
    <steppedValueSet variable="tau2" first="0" step="3" last="60"/>
    <enumeratedValueSet variable="dispersal_radius_larvae">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_larvae">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defense-tolerance">
      <value value="0.24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-below-ground">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="larva-waves">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resource-limitation-above">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="below-competition">
      <value value="&quot;complete symmetry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level-GA">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_defense_level">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="randomseed">
      <value value="98"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plant-number">
      <value value="242"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="above-competition">
      <value value="&quot;complete asymmetry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defense_fraction_all">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resource-limitation-below">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-threshold">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wave-delay">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intrinsic-growth-rate">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="switch?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Delay_time" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count plants</metric>
    <metric>productivity</metric>
    <enumeratedValueSet variable="movement-modus">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="display-below-ground">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="randomseed" first="11" step="1" last="30"/>
    <enumeratedValueSet variable="switch?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level-GA">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_defense_level">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plant-number">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wave-delay">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau-range">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_larvae">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="larva-waves">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="local">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tau-median">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="wave-larvae">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death_coeff">
      <value value="0.25"/>
    </enumeratedValueSet>
    <steppedValueSet variable="tau1" first="0" step="6" last="42"/>
    <enumeratedValueSet variable="resource-limitation-above">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intrinsic-growth-rate">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dispersal_radius_larvae">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="above-competition">
      <value value="&quot;complete asymmetry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-threshold">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defense_fraction_all">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="below-competition">
      <value value="&quot;complete symmetry&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resource-limitation-below">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="frequency">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defense-tolerance">
      <value value="0.24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conversion-factor">
      <value value="0.18"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@
