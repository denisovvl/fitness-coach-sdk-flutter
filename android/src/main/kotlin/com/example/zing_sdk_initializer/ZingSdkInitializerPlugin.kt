package com.example.zing_sdk_initializer

import android.content.Context
import android.util.Log
import coach.zing.fitness.coach.CoachesAvailability
import coach.zing.fitness.coach.Configuration
import coach.zing.fitness.coach.GenderAvailability
import coach.zing.fitness.coach.SdkAuthentication
import coach.zing.fitness.coach.StartingRoute
import coach.zing.fitness.coach.ZingSdk
import coach.zing.fitness.coach.ZingSdkActivity
import coach.zing.fitness.coach.ZingSdkTheme
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class ZingSdkInitializerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    companion object {
        private const val CHANNEL_NAME = "zing_sdk_initializer"
        private const val AUTH_STATE_CHANNEL_NAME = "zing_sdk_initializer/auth_state"
        private const val AUTH_TOKEN_CALLBACK_CHANNEL_NAME =
            "zing_sdk_initializer/auth_token_callback"
        private const val TAG = "ZingSdkInitializer"
        private const val METHOD_INIT = "init"
        private const val METHOD_LOGIN = "login"
        private const val METHOD_LOGOUT = "logout"
        private const val METHOD_OPEN_SCREEN = "openScreen"
        private const val ARG_ROUTE = "route"

        private object RouteKeys {
            const val HOME = "home"
            const val CUSTOM_WORKOUT = "custom_workout"
            const val AI_ASSISTANT = "ai_assistant"
            const val WORKOUT_PLAN_DETAILS = "workout_plan_details"
            const val FULL_SCHEDULE = "full_schedule"
            const val PROFILE_SETTINGS = "profile_settings"
        }
    }

    private lateinit var channel: MethodChannel
    private lateinit var authStateEventChannel: EventChannel
    private lateinit var authTokenCallbackChannel: MethodChannel
    private var activityContext: Context? = null
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)

        authStateEventChannel = EventChannel(binding.binaryMessenger, AUTH_STATE_CHANNEL_NAME)
        authStateEventChannel.setStreamHandler(AuthStateStreamHandler(scope))

        authTokenCallbackChannel =
            MethodChannel(binding.binaryMessenger, AUTH_TOKEN_CALLBACK_CHANNEL_NAME)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        authStateEventChannel.setStreamHandler(null)
        scope.cancel()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_INIT -> handleInit(call, result)
            METHOD_LOGIN -> handleLogin(result)
            METHOD_LOGOUT -> handleLogout(result)
            METHOD_OPEN_SCREEN -> handleOpenScreen(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleInit(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            runCatching {
                val type = call.argument<String>("type")
                val auth = when (type) {
                    "apiKey" -> {
                        val apiKey = call.argument<String>("apiKey")
                            ?: throw IllegalArgumentException("apiKey is required")
                        SdkAuthentication.ApiKey(apiKey = apiKey)
                    }

                    "externalToken" -> {
                        SdkAuthentication.ExternalToken(
                            authTokenCallback = FlutterAuthTokenCallback(authTokenCallbackChannel)
                        )
                    }

                    else -> throw IllegalArgumentException("Unknown auth type: $type")
                }
                val themeMap = call.argument<Map<String, Any>>("theme")
                val theme = themeMap?.let { buildTheme(it) }

                val configMap = call.argument<Map<String, Any>>("configuration")
                val configuration = configMap?.let { buildConfiguration(it) }

                ZingSdk.init(auth, theme, configuration)
                Log.i(TAG, "Zing SDK initialized with auth type: $type")
                result.success(null)
            }.onFailure { throwable ->
                Log.e(TAG, "Failed to initialize Zing SDK", throwable)
                result.error(
                    "native_init_failed",
                    throwable.message,
                    Log.getStackTraceString(throwable)
                )
            }
        }
    }

    private fun handleLogin(result: MethodChannel.Result) {
        scope.launch {
            runCatching {
                ZingSdk.login()
                Log.i(TAG, "Zing SDK login")
                result.success(null)
            }.onFailure { throwable ->
                Log.e(TAG, "Failed to login Zing SDK", throwable)
                result.error(
                    "login_failed",
                    throwable.message,
                    Log.getStackTraceString(throwable)
                )
            }
        }
    }

    private fun handleLogout(result: MethodChannel.Result) {
        scope.launch {
            runCatching {
                ZingSdk.logout()
                result.success(null)
            }.onFailure { throwable ->
                Log.e(TAG, "Failed to logout Zing SDK", throwable)
                result.error(
                    "logout_failed",
                    throwable.message,
                    Log.getStackTraceString(throwable)
                )
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityContext = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityContext = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityContext = binding.activity
    }

    override fun onDetachedFromActivity() {
        activityContext = null
    }

    private fun handleOpenScreen(call: MethodCall, result: MethodChannel.Result) {
        val routeKey = call.argument<String>(ARG_ROUTE)
        if (routeKey.isNullOrBlank()) {
            result.error("missing_route", "Route argument is required", null)
            return
        }

        val startingRoute = when (routeKey) {
            RouteKeys.HOME -> StartingRoute.Home
            RouteKeys.CUSTOM_WORKOUT -> StartingRoute.CustomWorkout
            RouteKeys.AI_ASSISTANT -> StartingRoute.AiAssistant
            RouteKeys.WORKOUT_PLAN_DETAILS -> StartingRoute.WorkoutPlanDetails
            RouteKeys.FULL_SCHEDULE -> StartingRoute.FullSchedule
            RouteKeys.PROFILE_SETTINGS -> StartingRoute.ProfileSettings
            else -> null
        }

        if (startingRoute == null) {
            result.error(
                "unknown_route",
                "Route $routeKey is not supported",
                null
            )
            return
        }

        val context = activityContext
        if (context == null) {
            result.error("no_activity", "No activity context available", null)
            return
        }

        runCatching {
            ZingSdkActivity.launch(context, startingRoute)
            result.success(null)
        }.onFailure { throwable ->
            Log.e(TAG, "Failed to launch route $routeKey", throwable)
            result.error(
                "launch_failed",
                throwable.message,
                Log.getStackTraceString(throwable)
            )
        }
    }

    private fun buildTheme(themeMap: Map<String, Any>): ZingSdkTheme? {
        @Suppress("UNCHECKED_CAST")
        val colorsMap = themeMap["colors"] as? Map<String, Any> ?: return null

        fun color(key: String): Long? = (colorsMap[key] as? Number)?.toLong()

        val colors = ZingSdkTheme.Colors(
            brandPrimary = color("brand/primary"),
            brandSecondary = color("brand/secondary"),
            brandTertiary = color("brand/tertiary"),
            textHeadlineDarkPrimary = color("text/heading/dark-primary"),
            textHeadlineLightPrimary = color("text/heading/light-primary"),
            textBodyDarkPrimary = color("text/body/dark-primary"),
            textBodyDarkSecondary = color("text/body/dark-secondary"),
            textBodyLightPrimary = color("text/body/light-primary"),
            textBodyLightSecondary = color("text/body/light-secondary"),
            textBodyBluePrimary = color("text/body/blue-primary"),
            textBodyBlueSecondary = color("text/body/blue-secondary"),
            textBodyYellowPrimary = color("text/body/yellow-primary"),
            textBodyOrchidPrimary = color("text/body/orchid-primary"),
            overlayBlackDark = color("overlay/black-dark"),
            overlayBlackMedium = color("overlay/black-medium"),
            overlayCadetMedium = color("overlay/cadet-medium"),
            buttonBgDarkPrimary = color("button/bg-dark-primary"),
            buttonBgDarkSecondary = color("button/bg-dark-secondary"),
            buttonBgLightPrimary = color("button/bg-light-primary"),
            buttonBgLightSecondary = color("button/bg-light-secondary"),
            buttonBgLightYellow = color("button/bg-light-yellow"),
            buttonBgLightOrchid = color("button/bg-light-orchid"),
            buttonBgLightBlue = color("button/bg-light-blue"),
            buttonBgIconTransparent = color("button/bg-icon-transparent"),
            bgWrite = color("bg/white"),
            bgLightGrey = color("bg/light-grey"),
        )

        return ZingSdkTheme(colors = colors)
    }

    private fun buildConfiguration(configMap: Map<String, Any>): Configuration {
        val coachesAvailability = when (configMap["coachesAvailability"] as? String) {
            "allCoaches" -> CoachesAvailability.ALL_COACHES
            "userGenderBased" -> CoachesAvailability.USER_GENDER_BASED
            else -> null
        }
        val genderAvailability = when (configMap["genderAvailability"] as? String) {
            "all" -> GenderAvailability.ALL
            "binary" -> GenderAvailability.BINARY
            else -> null
        }
        return Configuration(
            coachesAvailability = coachesAvailability,
            genderAvailability = genderAvailability,
        )
    }
}
