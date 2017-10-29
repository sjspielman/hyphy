RequireVersion("2.3.4");
LoadFunctionLibrary("libv3/UtilityFunctions.bf");
LoadFunctionLibrary("libv3/IOFunctions.bf");
LoadFunctionLibrary("libv3/stats.bf");
LoadFunctionLibrary("libv3/all-terms.bf");

LoadFunctionLibrary("libv3/tasks/ancestral.bf");
LoadFunctionLibrary("libv3/tasks/alignments.bf");
LoadFunctionLibrary("libv3/tasks/estimators.bf");
LoadFunctionLibrary("libv3/tasks/trees.bf");
LoadFunctionLibrary("libv3/tasks/mpi.bf");
LoadFunctionLibrary("libv3/convenience/math.bf");

LoadFunctionLibrary("libv3/models/rate_variation.bf");

LoadFunctionLibrary("libv3/models/protein/empirical.bf");
LoadFunctionLibrary("libv3/models/protein/REV.bf");
LoadFunctionLibrary("libv3/models/protein.bf");
LoadFunctionLibrary("ProteinGTRFit_helper.ibf");


/*------------------------------------------------------------------------------*/

utility.ToggleEnvVariable ("NORMALIZE_SEQUENCE_NAMES", 1);
utility.ToggleEnvVariable ("PRODUCE_OPTIMIZATION_LOG", 1); 

//utility.ToggleEnvVariable ("OPTIMIZATION_PRECISION", 1); // Uncomment for testing to make it all run faster.



protein_gtr.analysis_banner = {
    terms.io.info: "Fit a general time reversible model to a collection
    of training protein sequence alignments. Generate substitution
    and scoring matrices following the procedures described in Nickle et al 2007",
    terms.io.version: "0.01",
    terms.io.reference: "Nickle DC, Heath L, Jensen MA, Gilbert PB, Mullins JI, Kosakovsky Pond SL (2007) HIV-Specific Probabilistic Models of Protein Evolution. PLoS ONE 2(6): e503. doi:10.1371/journal.pone.0000503",
    terms.io.authors: "Sergei L Kosakovsky Pond and Stephanie J Spielman",
    terms.io.contact: "{spond,stephanie.spielman}@temple.edu"
};
io.DisplayAnalysisBanner(protein_gtr.analysis_banner);


protein_gtr.filename_to_index = terms.data.filename_to_index;
protein_gtr.logl = terms.fit.log_likelihood;
protein_gtr.phase = terms.fit.phase;
protein_gtr.json.information = "information";
protein_gtr.baseline_phase = "Baseline Phase";
protein_gtr.final_phase    = "REV-Final";
protein_gtr.rev_phase_prefix = "REV-Phase-";
protein_gtr.bl_phase_prefix = "REV-local-Phase-";
protein_gtr.options.convergence_type = "convergence type";
protein_gtr.options.tolerance        = "tolerance";
protein_gtr.options.baseline_model   = "baseline model";
protein_gtr.options.rate_variation   = "use rate variation";

protein_gtr.analysis_results = {terms.json.analysis: protein_gtr.analysis_banner,
                                terms.json.input: {},
                                terms.json.timers: {}};
                                
protein_gtr.timers = {};


/********************************************** MENU PROMPTS ********************************************************/
/********************************************************************************************************************/

// Load file containing paths to alignments for fitting and assess whether to start from scratch or resume a cached analysis

SetDialogPrompt ("Supply a list of files to include in the analysis (one per line)");
fscanf (PROMPT_FOR_FILE, "Lines", protein_gtr.file_list);
protein_gtr.listfile = utility.getGlobalValue("LAST_FILE_PATH");
protein_gtr.json_file = protein_gtr.listfile  + ".json";
protein_gtr.final_likelihood_function = protein_gtr.listfile  + "_Final-Phase-LF.nex";
protein_gtr.file_list = io.validate_a_list_of_files (protein_gtr.file_list);
protein_gtr.file_list_count = Abs (protein_gtr.file_list);
protein_gtr.index_to_filename = utility.SwapKeysAndValues(protein_gtr.file_list);
/********* PROMPTS **********/


// Prompt for convergence assessment type
//protein_gtr.convergence_type = io.SelectAnOption( protein_gtr.convergence_options, "Select a convergence criterion.");
protein_gtr.convergence_type = "RMSE";

// Prompt for threshold
//protein_gtr.tolerance = io.PromptUser ("\n>Provide a tolerance level for convergence assessment (Default 0.01)",0.01,0,1,FALSE); // default, lower, upper, is_integer
protein_gtr.tolerance = 0.1;

// Prompt for baseline AA model
//protein_gtr.baseline_model  = io.SelectAnOption (models.protein.empirical_models,
//                                                "Select an empirical protein model to use for optimizing the provided branch lengths (we recommend LG):");
protein_gtr.baseline_model = "LG";

// Prompt for rate variation
protein_gtr.use_rate_variation = io.SelectAnOption( protein_gtr.rate_variation_options, "Would you like to optimize branch lengths with rate variation?");

protein_gtr.save_options();


if (protein_gtr.use_rate_variation == "Gamma"){
    protein_gtr.baseline_model_name      = protein_gtr.baseline_model + "+F, with 4 category Gamma rates";
    protein_gtr.baseline_model_desc      = "protein_gtr.Baseline.ModelDescription.withGamma";
    protein_gtr.rev_model_intermediate   = "protein_gtr.REV.ModelDescription.withGamma";
    protein_gtr.rev_model_final          = "models.protein.REVML.ModelDescription.withGamma";
}  
else {
    if (protein_gtr.use_rate_variation == "GDD"){
        protein_gtr.baseline_model_name      = protein_gtr.baseline_model + "+F, with 4 category GDD rates";
        protein_gtr.baseline_model_desc      = "protein_gtr.Baseline.ModelDescription.withGDD4";
        protein_gtr.rev_model_intermediate   = "protein_gtr.REV.ModelDescription.withGDD4";
        protein_gtr.rev_model_final          = "models.protein.REVML.ModelDescription.withGDD4";
    } 
    else {
        protein_gtr.baseline_model_name      = protein_gtr.baseline_model + "+F";
        protein_gtr.baseline_model_desc      = "protein_gtr.Baseline.ModelDescription";
        protein_gtr.rev_model_intermediate   = "protein_gtr.REV.ModelDescription";
        protein_gtr.rev_model_final          = "models.protein.REVML.ModelDescription";
    }
}
/********************************************************************************************************************/



protein_gtr.startTimer (protein_gtr.timers, "Total time");


protein_gtr.queue = mpi.CreateQueue ({  utility.getGlobalValue("terms.mpi.Headers")   : utility.GetListOfLoadedModules ("libv3/") ,
                                        utility.getGlobalValue("terms.mpi.Functions") :
                                        {
                                            {"models.protein.REV.ModelDescription.withGamma",
                                             "models.protein.REV.ModelDescription.withGDD4",
                                             "protein_gtr.REV.ModelDescription",
                                             "protein_gtr.REV.ModelDescription.withGamma",
                                             "protein_gtr.REV.ModelDescription.withGDD4",
                                             "protein_gtr.REV.ModelDescription.freqs",
                                             "protein_gtr.Baseline.ModelDescription.withGamma",
                                             "protein_gtr.Baseline.ModelDescription.withGDD4",
                                             "protein_gtr.Baseline.ModelDescription",
                                             "protein_gtr.fitBaselineToFile"
                                            }
                                        },
                                        utility.getGlobalValue("terms.mpi.Variables") : {{
                                            "protein_gtr.shared_EFV",
                                            "protein_gtr.baseline_model_desc",
                                            "protein_gtr.rev_model_intermediate",
                                            "protein_gtr.rev_model_final",
                                            "protein_gtr.baseline_model",
                                            "protein_gtr.index_to_filename",
                                            "protein_gtr.analysis_results",
                                            "protein_gtr.baseline_phase"
                                        }}
                                     });
  

                        
io.ReportProgressMessageMD ("Protein GTR Fitter", "Initial branch length fit", "Initial branch length fit");

protein_gtr.fit_phase = 0;
protein_gtr.scores = {};

/*************************** STEP ONE ***************************
Perform an initial fit of Baseline model+F(+/-4G) to the data (or load cached fit.)
*****************************************************************/
console.log("\n\n[PHASE 1] Performing initial branch length optimization using " + protein_gtr.baseline_model);

protein_gtr.startTimer (protein_gtr.timers, protein_gtr.baseline_phase);
protein_gtr.timer_count +=1; 

for (file_index = 0; file_index < protein_gtr.file_list_count; file_index += 1) {

     io.ReportProgressMessageMD ("Protein GTR Fitter", " * Initial branch length fit",
                                     "Dispatching file '" + protein_gtr.file_list[file_index]);


    mpi.QueueJob (protein_gtr.queue, "protein_gtr.fitBaselineToFile", {"0" : protein_gtr.file_list[file_index]},
                                                            "protein_gtr.handle_baseline_callback");
}
mpi.QueueComplete (protein_gtr.queue);

protein_gtr.stopTimer (protein_gtr.timers, protein_gtr.baseline_phase);

// Sum of the logL from fitted baseline model across each data set
protein_gtr.baseline_fit_logL = math.Sum (utility.Map (utility.Filter (protein_gtr.analysis_results, "_value_", "_value_/protein_gtr.baseline_phase"), "_value_", "(_value_[protein_gtr.baseline_phase])[terms.fit.log_likelihood]"));
io.ReportProgressMessageMD ("Protein GTR Fitter", " * Initial branch length fit",
                            "Overall Log(L) = " + protein_gtr.baseline_fit_logL);



console.log("\n\n Optimizing model in full, single pass.");


protein_gtr.startTimer (protein_gtr.timers, protein_gtr.final_phase);

current = utility.Map (utility.Filter (protein_gtr.analysis_results, "_value_", "_value_/'" + protein_gtr.baseline_phase + "'"), "_value_", "_value_['" + protein_gtr.baseline_phase + "']");

protein_gtr.current_gtr_fit = protein_gtr.fitOnePass(current);
                                                            
                                                            
protein_gtr.stopTimer (protein_gtr.timers, protein_gtr.final_phase);



/* Save the JSON */
protein_gtr.stopTimer (protein_gtr.timers, "Total time");
protein_gtr.analysis_results[terms.json.timers] = protein_gtr.timers;
io.SpoolJSON(protein_gtr.analysis_results, protein_gtr.json_file);