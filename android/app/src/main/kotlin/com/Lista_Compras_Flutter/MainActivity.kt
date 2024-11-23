package com.Lista_Compras_Flutter

import android.os.Bundle
import com.android.billingclient.api.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private lateinit var billingClient: BillingClient
    private var isPremiumUser: Boolean = false // Status do usuário premium
    private val CHANNEL = "com.Lista_Compras_Flutter/premium"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Inicializa a biblioteca de faturamento
        billingClient = BillingClient.newBuilder(this)
            .setListener { billingResult, purchases ->
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && purchases != null) {
                    for (purchase in purchases) {
                        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
                            if (purchase.products.contains("premium_access")) {
                                isPremiumUser = true
                            }
                        }
                    }
                }
            }
            .enablePendingPurchases()
            .build()

        billingClient.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    checkPurchases() // Verifica se o usuário já comprou o produto premium
                }
            }

            override fun onBillingServiceDisconnected() {
                // Reconecte o cliente de faturamento, se necessário
            }
        })
    }

    private fun checkPurchases() {
        // Verifica compras ativas usando queryPurchasesAsync
        val params = QueryPurchasesParams.newBuilder()
            .setProductType(BillingClient.ProductType.INAPP)
            .build()

        billingClient.queryPurchasesAsync(params) { billingResult, purchases ->
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && purchases != null) {
                purchases.forEach { purchase ->
                    if (purchase.products.contains("premium_access")) {
                        isPremiumUser = true
                    }
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isPremiumUser" -> {
                    result.success(isPremiumUser) // Retorna o status premium para o Flutter
                }
                "purchasePremiumAccess" -> {
                    billingClient.queryProductDetailsAsync(
                        QueryProductDetailsParams.newBuilder()
                            .setProductList(
                                listOf(
                                    QueryProductDetailsParams.Product.newBuilder()
                                        .setProductId("premium_access")
                                        .setProductType(BillingClient.ProductType.INAPP)
                                        .build()
                                )
                            ).build()
                    ) { billingResult, productDetailsList ->
                        if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && productDetailsList.isNotEmpty()) {
                            val productDetails = productDetailsList[0] // Produto premium_access

                            // Inicia o fluxo de compra
                            val flowParams = BillingFlowParams.newBuilder()
                                .setProductDetailsParamsList(
                                    listOf(
                                        BillingFlowParams.ProductDetailsParams.newBuilder()
                                            .setProductDetails(productDetails)
                                            .build()
                                    )
                                ).build()

                            val responseCode = billingClient.launchBillingFlow(this, flowParams).responseCode
                            result.success(responseCode == BillingClient.BillingResponseCode.OK)
                        } else {
                            result.success(false) // Produto não encontrado ou erro na consulta
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }

    }
}
