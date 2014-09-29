/*
 *
 * Task code generated by SAS Studio 3.1 
 *
 * Generated on 'Mon Sep 22 2014 22:15:39 GMT+1000 (AUS Eastern Standard Time)' 
 * Generated by 'sasdemo' 
 * Generated on server 'LOCALHOST' 
 * Generated on SAS platform 'Linux LIN X64 2.6.32-431.11.2.el6.x86_64' 
 * Generated on SAS version '9.04.01M1P12042013' 
 * Generated on browser 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.120 Safari/537.36' 
 * Generated on web client 'http://192.168.138.128/SASStudio/main?locale=en_US&zone=GMT+-10%3A00' 
 *
 */

%web_drop_table(WORK.CharacterizeDataFRQ, WORK.CharacterizeDataUNI, 
    WORK.TTAFTempTableAccumFreq, WORK.TTAUTempTableAccumUniv, 
    WORK.TCONTempTableContents, WORK.TPFRTempTableFrequencies2, 
    WORK.TPUNTempTableUnivariate2, WORK.TFFRTempFormatFreqs);

%MACRO REPORTS;
    %let date_fmts = "B8601DA", "DATE", "DAY", "DDMMYY", "DDMMYYB", "DDMMYYC", 
        "DDMMYYD", "DDMMYYN", "DDMMYYP", "DDMMYYS", "DOWNAME", "E8601DA", 
        "EURDFDD", "EURDFDE", "EURDFDN", "EURDFDWN", "EURDFMN", "EURDFMY", 
        "EURDFWDX", "EURDFWKX", "HDATE", "HEBDATE", "JULDAY", "JULIAN", 
        "MINGUO", "MMDDYY", "MMDDYYB", "MMDDYYC", "MMDDYYD", "MMDDYYN", 
        "MMDDYYP", "MMDDYYS", "MMYY", "MMYYC", "MMYYD", "MMYYN", "MMYYP", 
        "MMYYS", "MONNAME", "MONTH", "MONYY", "NENGO", "NLDATE", "NLDATEMN", 
        "NLDATEW", "NLDATWN", "QTR", "QTRR", "WEEKDATE", "WEEKDATX", "WEEKDAY", 
        "WEEKU", "WEEKV", "WEEKW", "WORDDATE", "WORDDATX", "YEAR", "YYMM", 
        "YYMMC", "YYMMD", "YYMMDD", "YYMMDDB", "YYMMDDC", "YYMMDDD", "YYMMDDN", 
        "YYMMDDP", "YYMMDDS", "YYMMN", "YYMMP", "YYMMS", "YYMON", "YYQ", 
        "YYQC", "YYQD", "YYQN", "YYQP", "YYQR", "YYQRC", "YYQRD", "YYQRN", 
        "YYQRP", "YYQRS", "YYQS";
    %let time_fmts = "B8601LZ", "B8601TM", "B8601TX", "B8601TZ", "E8601LZ", 
        "E8601TM", "E8601TX", "B8601TZ", "HHMM", "HOUR", "MMSS", "MMSSC", 
        "MMSSD", "MMSSN", "MMSSP", "MMSSS", "NLTIMAP", "NLTIME", "TIME", 
        "TIMEAMPM", "TOD";
    %let dt_fmts = "B8601DN", "B8601DT", "B8601DX", "B8601DZ", "B8601LX", 
        "DATEAMPM", "DATETIME", "DTDATE", "DTMONYY", "DTWKDATX", "DTYEAR", 
        "DTYYQC", "EURDFDT" "E8601DN", "E8601DT", "E8601DX", "E8601DZ", 
        "E8601LX", "MDYAMPM", "NLDATMW", "NLDATM", "NLDATMAP", "NLDATMTM", 
        "NLTIMAP";
    %let curr_fmts = "DOLLAR", "DOLLARX", "EURO", "EUROX", "NLMNY", "NLMNYI", 
        "YEN";

    %if &charVarsFlag=1 %then
        %do;
            options MISSING=' ' PAGENO=1;
            title;
            title1 "Summary of Character Variables for &DATA";
            title2 
                "Limited to the 30 Most Frequent Distinct Values per Variable";
            footnote;
            footnote1 "Generated by the SAS System on %trim(%qsysfunc(DATE(), NLDATE20.)) at %trim(%sysfunc(TIME(), TIMEAMPM12.))";

            proc print data=WORK.TTAFTempTableAccumFreq label;
                by Variable Label;
                id Variable Label;
                var Value Count Percent;
                format Label;
                ;
            run;

        %end;
    %else
        %do;
            options MISSING=' ' PAGENO=1;
            title;
            title1 "Summary of Character Variables for &DATA";
            title2;
            footnote;
            footnote1 "Generated by the SAS System on %trim(%qsysfunc(DATE(), NLDATE20.)) at %trim(%sysfunc(TIME(), TIMEAMPM12.))";

            data _NULL_;
                FILE print;
                PUT /// "NO CHARACTER VARIABLES WERE FOUND in THE INPUT DATA";
                stop;
            run;

        %end;

    %if &numVarsFlag=1 %then
        %do;

            /* -------------------------------------------------------------------
            Determine which date, time, datetime and
            currency formats are most frequently associated
            with variables in the input data set.  Those
            formats will then be used to display the date,
            time, datetime and currency variable values in
            their respective summary reports.
            ------------------------------------------------------------------- */
            proc freq data=WORK.TTAUTempTableAccumUniv noprint;
                TABLES format / out=WORK.TFFRTempFormatFreqs;
            run;

            proc sort data=WORK.TFFRTempFormatFreqs;
                by DESCENDING COUNT;
            run;

            %let _SS_DATE_FMT=DATE;
            %let _SS_TIME_FMT=TIME;
            %let _SS_DATETIME_FMT=DATETIME;
            %let _SS_CURRENCY_FMT=DOLLAR;

            data _NULL_;
                retain dateFound timeFound datetimeFound currencyFound 0;
                set WORK.TFFRTempFormatFreqs;

                if format in (&DATE_FMTS) then
                    do;

                        if dateFound=0 then
                            do;
                                call symputx("_SS_DATE_FMT", FORMAT);
                                dateFound=1;
                            end;
                        return;
                    end;

                if format in (&TIME_FMTS) then
                    do;

                        if timeFound=0 then
                            do;
                                call symputx("_SS_TIME_FMT", FORMAT);
                                timeFound=1;
                            end;
                        return;
                    end;

                if format in (&DT_FMTS) then
                    do;

                        if datetimeFound=0 then
                            do;
                                call symputx("_SS_DATETIME_FMT", FORMAT);
                                datetimeFound=1;
                            end;
                        return;
                    end;

                if format in (&CURR_FMTS) or substr(FORMAT, 1, 5)="EURFR" or 
                    substr(FORMAT, 1, 5)="EURTO" then
                        do;

                        if currencyFound=0 then
                            do;
                                call symputx("_SS_CURRENCY_FMT", FORMAT);
                                currencyFound=1;
                            end;
                        return;
                    end;
            run;

            proc sort data=WORK.TTAUTempTableAccumUniv;
                by variable label;
            run;

            title;
            title1 
                "Summary of Numeric (Not Date or Currency) Variables for &DATA";
            footnote;
            footnote1 "Generated by the SAS System on %trim(%qsysfunc(DATE(), NLDATE20.)) at %trim(%sysfunc(TIME(), TIMEAMPM12.))";

            proc print data=WORK.TTAUTempTableAccumUniv;
                where format NOT in (&DATE_FMTS, &TIME_FMTS, &DT_FMTS, 
                    &CURR_FMTS) AND format NOT LIKE "EURFR%" AND format NOT 
                    LIKE "EURTO%";
                by variable label;
                id variable label;
                var n nmiss total min mean median max stdmean;
                format Label;
            run;

            title;
            title1 "Summary of Currency Variables for &DATA";

            proc print data=WORK.TTAUTempTableAccumUniv;
                where format in (&CURR_FMTS) or format LIKE "EURFR%" or format 
                    LIKE "EURTO%";
                by variable label;
                id variable label;
                var n nmiss total min mean median max stdmean;
                format total mean stdmean min median max &_SS_CURRENCY_FMT.16.2;
                format Label;
            run;

            title;
            title1 "Summary of Date Variables for &DATA";

            proc print data=WORK.TTAUTempTableAccumUniv;
                where format in (&DATE_FMTS);
                by variable label;
                id variable label;
                var n nmiss min mean median max;
                format min mean median max &_SS_DATE_FMT..;
                format Label;
            run;

            title;
            title1 "Summary of Time Variables for &DATA";

            proc print data=WORK.TTAUTempTableAccumUniv;
                where format in (&TIME_FMTS);
                by variable label;
                id variable label;
                var n nmiss min mean median max;
                format min mean median max &_SS_TIME_FMT..;
                format Label;
            run;

            title;
            title1 "Summary of Datetime Variables for &DATA";

            proc print data=WORK.TTAUTempTableAccumUniv;
                where format in (&DT_FMTS);
                by variable label;
                id variable label;
                var n nmiss min mean median max;
                format min mean median max &_SS_DATETIME_FMT..;
                format Label;
            run;

        %end;
    %else
        %do;
            title;
            title1 "Summary of Numeric Variables for &DATA";
            footnote;
            footnote1 "Generated by the SAS System on %trim(%qsysfunc(DATE(), NLDATE20.)) at %trim(%sysfunc(TIME(), TIMEAMPM12.))";

            data _NULL_;
                FILE print;
                PUT /// "NO NUMERIC VARIABLES WERE FOUND in THE INPUT DATA";
                stop;
            run;

        %end;
%MEND REPORTS;

%MACRO CHARTS;
    %if &charVarsFlag=1 %then
        %do;

            proc sort data=WORK.TTAFTempTableAccumFreq;
                by Variable;
            run;

            title;
            title1 "Character Variable Value Counts for &DATA";

            proc SGPLOT data=WORK.TTAFTempTableAccumFreq NOAUTOLEGend;
                YAXIS FITPOLICY=THIN;
                HBAR value / STAT=SUM RESPONSE=COUNT GROUP=value;
                by Variable;
            run;

            quit;
        %end;

    %if &numVarsFlag=1 %then
        %do;

            proc sort data=WORK.TTAUTempTableAccumUniv;
                by Variable;
            run;

            %let dsid=%sysfunc(open(WORK.TTAUTempTableAccumUniv));
            %let numobs =%sysfunc(attrn(&dsid, nlobs));
            %let rc=%sysfunc(close(&dsid));

            %do obsNumber=1 %to &numobs;

                /* -------------------------------------------------------------------
                We need to determine the SAS format associated
                with the current variable so that we can format
                the means and median values appropriately for
                use in the charts' footnotes.
                ------------------------------------------------------------------- */
                data _NULL_;
                    pointer=&obsNumber;
                    set WORK.TTAUTempTableAccumUniv POINT=pointer;
                    dsid=OPEN("&data", "i");

                    if dsid > 0 then
                        do;
                            varno=VARNUM(dsid, Variable);
                            format=" ";

                            if varno > 0 then
                                format=VARFMT(dsid, varno);

                            if format NE " " then
                                call symputx("_SS_VAR_FMT", format);
                            else
                                call symputx("_SS_VAR_FMT", "BEST12.");
                            rc=CLOSE(dsid);
                        end;
                    else
                        call symputx("_SS_VAR_FMT", "BEST12.");
                    stop;
                run;

                data _NULL_;
                    pointer=&obsNumber;
                    set WORK.TTAUTempTableAccumUniv POINT=pointer;
                    call symputx('var', Variable);
                    call symputx('var_n', quote(trim(Variable)) || "n");
                    call symputx('mean', PUT(mean, &_SS_VAR_FMT));
                    call symputx('median', PUT(median, &_SS_VAR_FMT));
                    stop;
                run;

                title;
                title1 "Numeric Variable Values for &DATA";
                footnote;
                footnote1 'Mean = ' "&mean";
                footnote2 'Median = ' "&median";
                footnote3 ' ';

                proc SGPLOT data=&data NOAUTOLEGend;
                    XAXIS FITPOLICY=THIN;
                    VBAR &var_n / STAT=freq GROUP=&var_n;
                run;

                quit;
            %end;
        %end;
%MEND CHARTS;

/* -------------------------------------------------------------------
Define the variables in the output data sets so that they
will exist when proc append uses them as the BASE data set.
------------------------------------------------------------------- */
data WORK.CharacterizeDataFRQ(label=Frequency Counts for ORION.SALES);
    length DataSet $ 41 Variable $32 Label $ 256 Format $ 31 Value $ 32 Count 
        Percent 8;
    label Count='Frequency Count' Percent='Percent of Total Frequency';
    retain DataSet Variable Label Format Value ' ' Count Percent 0;
    stop;
run;

data WORK.CharacterizeDataUNI(label=Univariate Statistics for ORION.SALES);
    length DataSet $ 41 Variable $32 Label $ 256 Format $ 31 N NMiss Total Min 
        Mean Median Max StdMean 8;
    retain DataSet Variable Label Format ' ' N NMiss Total Min Mean Median Max 
        StdMean 0;
    stop;
run;

%MACRO _SS_CHARACTERIZE(data, lib, dsn, catobs);
    /* -------------------------------------------------------------------
    Define the variables in the work accumulation data sets
    and clear them out so that we can record the statistics for
    the current data set.
    ------------------------------------------------------------------- */
    data WORK.TTAFTempTableAccumFreq;
        length DataSet $ 41 Variable $32 Label $ 256 Format $ 31 Value $ 32 
            Count Percent 8;
        label Count='Frequency Count' Percent='Percent of Total Frequency';
        retain DataSet Variable Label Format Value ' ' Count Percent 0;
        stop;
    run;

    data WORK.TTAUTempTableAccumUniv;
        length DataSet $ 41 Variable $32 Label $ 256 Format $ 31 N NMiss Total 
            Min Mean Median Max StdMean 8;
        retain DataSet Variable Label Format ' ' N NMiss Total Min Mean Median 
            Max StdMean 0;
        stop;
    run;

    /* -------------------------------------------------------------------
    Get all the variable information for the input data set.
    ------------------------------------------------------------------- */
    proc contents data=&data
	out=WORK.TCONTempTableContents noprint;
    run;

    /* -------------------------------------------------------------------
    Get the number of variables in the input data set.
    ------------------------------------------------------------------- */
	
	%let dsid=%sysfunc(open(WORK.TCONTempTableContents));
    %let numobs =%sysfunc(attrn(&dsid, nlobs));
    %let rc=%sysfunc(close(&dsid));

    /* -------------------------------------------------------------------
    Each time the macro is executed the macro variable
    type flags have to be initialized. They are used by
    the graphing, reporting and output data set generation
    code to determine if data exists to be processed.
    ------------------------------------------------------------------- */
	%let charVarsFlag = 0;
    %let numVarsFlag = 0;

    /* -------------------------------------------------------------------
    Loop for each variable in the input data set and
    depending on its type (character or numeric) gather
    the relevant statistics for its values.
    ------------------------------------------------------------------- */

    
    
    %do i=1 %to &numobs;

        /* -------------------------------------------------------------------
        Create macro variables to provide information about
        the current variable to subsequent data and PROC
        steps.
        ------------------------------------------------------------------- */
        data _NULL_;
            POINTER=&i;
            set WORK.TCONTempTableContents point=pointer;
            call symputx('var', name);
            call symputx('var_n', QUOTE(strip(name)) || "n");
            call symputx('type', PUT(type, 1.));
            call symputx('label', label);
            call symputx('format', format);
            stop;
        run;

        /* -------------------------------------------------------------------
        Process the variable if it is numeric.
        ------------------------------------------------------------------- */
	
        
        
        %if &type=1 %then
            %do;

                /* -------------------------------------------------------------------
                Set the macro variable flag to indicate that the
                input data set contains at least one numeric
                variable.
                ------------------------------------------------------------------- */
		%let numVarsFlag = 1;

                /* -------------------------------------------------------------------
                Get the statistics for the numeric variable.
                ------------------------------------------------------------------- */
                proc UNIVARIATE data=&data noprint;
                    var &var_n;
                    OUTPUT out=WORK.TPUNTempTableUnivariate2 N=N NMISS=NMiss 
                        MEAN=Mean MIN=Min MAX=Max MEDIAN=Median STDMEAN=StdMean 
                        SUM=Total;
                run;

                /* -------------------------------------------------------------------
                Append the statistics for the numeric variable
                to the data set used to accumulate information
                about numeric variables in the current data
                set.
                ------------------------------------------------------------------- */
                data WORK.TTAUTempTableAccumUniv;
                    set WORK.TTAUTempTableAccumUniv 
                        WORK.TPUNTempTableUnivariate2(IN=intemp);

                    if intemp=1 then
                        do;
                            Variable="&var";
                            Label="%superq(label)";
                            DataSet="&lib..&dsn";
                            Format="&FORMAT";
                        end;
                run;

            %end;

        /* -------------------------------------------------------------------
        Process the variable if it is character.
        ------------------------------------------------------------------- */
	%else
            %do;

                /* -------------------------------------------------------------------
                Set the macro variable flag to indicate that the
                input data set contains at least one
                character variable.
                ------------------------------------------------------------------- */
		%let charVarsFlag = 1;

                /* -------------------------------------------------------------------
                Get the frequency statistics for the values
                within the character variable.
                ------------------------------------------------------------------- */
                proc freq data=&data noprint;
                    TABLES &var_n/MISSING out=WORK.TPFRTempTableFrequencies2;
                run;

                /* -------------------------------------------------------------------
                Append the value frequency counts for the
                character variable to the data set used to
                accumulate information about all the character
                variables in the current data set.
                ------------------------------------------------------------------- */
                data WORK.TTAFTempTableAccumFreq;
                    drop InVar;
                    length Value $ 32;
                    set WORK.TTAFTempTableAccumFreq 
                        WORK.TPFRTempTableFrequencies2(IN=intemp 
                        RENAME=(&var_n=InVar));

                    if intemp=1THEN
                        do;
                            Value=InVar;
                            Variable="&var";
                            Label="%superq(label)";
                            DataSet="&lib..&dsn";
                            Format="&FORMAT";
                        end;
                run;

            %end;
    %end;

    /* -------------------------------------------------------------------
    Character data requires some additional
    processing.
    ------------------------------------------------------------------- */

    
    
    %if &charVarsFlag=1 %then
        %do;

            /* -------------------------------------------------------------------
            Sort the accumulated character variable
            information by name and value frequency count.
            ------------------------------------------------------------------- */
            proc sort data=WORK.TTAFTempTableAccumFreq;
                where dataset NE ' ';
                by variable label descending count;
            run;

            /* -------------------------------------------------------------------
            Provide a label for missing values and if
            the number of categorical values reported
            needs to be limited, then all categorical
            values' frequencies are accumulated into an
            additional "all others" item.
            ------------------------------------------------------------------- */
            data WORK.TTAFTempTableAccumFreq;
                drop i newcount newperc;
                retain i newcount newperc 0;
                set WORK.TTAFTempTableAccumFreq;
                by variable;

                if value=' ' then
                    value='***Missing***';

                %if &catobs NE -1 %then
                    %do;

                        if FIRST.variable then
                            i=1;
                        else
                            i+1;

                        if i > &catobs then
                            do;
                                newcount+count;
                                newperc+percent;
                            end;

                        if i >&catobs AND not(LAST.variable) then
                            DELETE;

                        if LAST.variable AND i > &catobs then
                            do;
                                value='***All other values***';
                                count=newcount;
                                percent=newperc;
                                newcount=0;
                                newperc=0;
                            end;
                    %end;
            run;

        %end;

    /* -------------------------------------------------------------------
    Calls the macro to generate the summary reports.
    ------------------------------------------------------------------- */
%REPORTS

    /* -------------------------------------------------------------------
    Calls the macro to generate the graphs.
    ------------------------------------------------------------------- */
%CHARTS

    /* -------------------------------------------------------------------
    Create the output data sets.
    ------------------------------------------------------------------- */
%if &charVarsFlag=1 %then %do;

    proc append BASE=WORK.CharacterizeDataFRQ data=WORK.TTAFTempTableAccumFreq 
            FORCE;
    run;

%end;

%if &numVarsFlag=1 %then
    %do;

        proc append BASE=WORK.CharacterizeDataUNI 
                data=WORK.TTAUTempTableAccumUniv FORCE;
        run;

    %end;
%MEND _SS_CHARACTERIZE;

%_SS_CHARACTERIZE(ORION.SALES, ORION, SALES, 30);

/* -------------------------------------------------------------------
End of task code.
------------------------------------------------------------------- */
run;
quit;
%web_drop_table(WORK.TTAFTempTableAccumFreq, WORK.TTAUTempTableAccumUniv, 
    WORK.TCONTempTableContents, WORK.TPFRTempTableFrequencies2, 
    WORK.TPUNTempTableUnivariate2, WORK.TFFRTempFormatFreqs);
%WEB_OPEN_TABLE(WORK.CharacterizeDataFRQ);
%WEB_OPEN_TABLE(WORK.CharacterizeDataUNI);
title;
footnote;