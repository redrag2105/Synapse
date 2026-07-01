package com.example.synapse;



import android.app.ActivityOptions;

import android.app.Instrumentation;

import android.content.Intent;

import android.os.Build;

import android.os.Bundle;

import android.os.ParcelFileDescriptor;

import androidx.test.platform.app.InstrumentationRegistry;

import java.io.BufferedReader;

import java.io.InputStreamReader;

import pl.leancode.patrol.Logger;

import pl.leancode.patrol.PatrolJUnitRunner;

import pl.leancode.patrol.PatrolServer;



/**

 * Workaround for MIUI / Android 12+ blocking background activity launches during

 * instrumentation (Patrol hangs on {@code waitForPatrolAppService()}).

 *

 * <p>Uses {@code am start} via UiAutomation shell so the activity is started from the

 * shell UID instead of the background instrumentation process.

 */

public class SynapsePatrolJUnitRunner extends PatrolJUnitRunner {

    private static final int LAUNCH_FLAGS =

            Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP;



    @Override

    public void setUp(Class<?> activityClass) {

        Logger.INSTANCE.i(

                "SynapsePatrolJUnitRunner.setUp(): activityClass = "

                        + activityClass.getCanonicalName());



        Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();



        PatrolServer patrolServer = new PatrolServer();

        patrolServer.start();



        String packageName = instrumentation.getTargetContext().getPackageName();

        String component = packageName + "/" + activityClass.getName();



        if (!launchViaShell(instrumentation, component)) {

            Intent intent = new Intent(Intent.ACTION_MAIN);

            intent.setClassName(packageName, activityClass.getName());

            intent.addFlags(LAUNCH_FLAGS);



            if (Build.VERSION.SDK_INT >= 34) {

                Bundle options =

                        ActivityOptions.makeBasic()

                                .setPendingIntentBackgroundActivityStartMode(

                                        ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED)

                                .toBundle();

                instrumentation.getTargetContext().startActivity(intent, options);

            } else {

                instrumentation.getTargetContext().startActivity(intent);

            }

            Logger.INSTANCE.i(

                    "SynapsePatrolJUnitRunner: launched via targetContext.startActivity");

        }



        patrolAppServiceClient = createAppServiceClient();

    }



    private static boolean launchViaShell(Instrumentation instrumentation, String component) {

        try {

            String cmd =

                    "am start -W -n "

                            + component

                            + " -f 0x"

                            + Integer.toHexString(LAUNCH_FLAGS);

            ParcelFileDescriptor pfd =

                    instrumentation.getUiAutomation().executeShellCommand(cmd);

            try (BufferedReader reader =

                    new BufferedReader(

                            new InputStreamReader(

                                    new ParcelFileDescriptor.AutoCloseInputStream(pfd)))) {

                String line;

                while ((line = reader.readLine()) != null) {

                    Logger.INSTANCE.i("SynapsePatrolJUnitRunner shell: " + line);

                }

            }

            Logger.INSTANCE.i("SynapsePatrolJUnitRunner: launched via shell am start");

            return true;

        } catch (Exception e) {

            Logger.INSTANCE.e("SynapsePatrolJUnitRunner: shell launch failed", e);

            return false;

        }

    }

}

