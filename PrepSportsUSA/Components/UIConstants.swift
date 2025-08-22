
//  UIConstants.swift

import UIKit
import Security
import Alamofire

class UIConstants: NSObject {
    
    static let appMainColor =  UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0)
    static let appMainDarkColor =  UIColor(red: 49/255.0, green: 148/255.0, blue: 97/255.0, alpha: 1.0)
     //= UIColor.orange //(red: 246.0/255.0, green: 129.0/255.0, blue: 33.0/255.0, alpha: 1)
    static let sliderColor = UIColor(red: 200/255, green: 45/255, blue: 0/255, alpha: 1)

    static let QRColor = UIColor(red: 20.0/255.0, green: 132.0/255.0, blue: 200.0/255.0, alpha: 1.0)
    static let bIsLive = false
    //new one
    static let BaseURL = bIsLive ? "https://secure.askaribank.com/mobilewebinterface/mobiledatamanager.asmx" : "https://mbibtest.askaribank.com.pk/mobilewebinterface/mobiledatamanager.asmx"
    
    static let SCREEN_BOUNDS                    = UIScreen.main.bounds
    
    static let IS_IPHONE5                       = UIScreen.main.bounds.size.height == 568 ? true : false
    
    static let USER_NAME                        = "name"
    static let LOGIN_TIME                       = "login_time"
    static let SESSION_ID                       = "session_id"
    static let CORPORATE_USER                   = "corporateuser"
    static let CNIC                             = "cnic"
    static let MOBILE_NUMBER                    = "mobilenumber"
    static let FP_DATA                          = "fpdata"
    static let PROFILE_EMAIL                    = "email"
    static let PAN_LOADED                       = "panloaded"
    static let PAN_OBJECT                       = "panobject"
    static let PROFILE_IMAGE                    = "image"
    static let PHONE_NUMBER                     = "phone"
    static let ADMIN_ID                         = "admin_id"
    static let PROFILE_LATITUDE                 = "latitude"
    static let PROFILE_LONGITUDE                = "longitude"
    static let PROFILE_ID                       = "ID"
    static let PROFILE_AREA                     = "area"
    static let PASSWORD                         = "password"
    static let PHONE_VALID                      = "phone_valid"
    static let ADDRESS_VALID                    = "address_valid"
    static let PROFILE_ADDRESS                  = "address"
    static let PROFILE_CITY                     = "city"
    static let PROFILE_ADDRESS_CODE             = "address_code"
    static let PROFILE_OTP                      = "otp"
    static let QR_API_KEY                       = "qrcode"
    static let FINGER_PRINT                     = "fingerprint"
    static let TEMP_FP_DATA                     = "fptempdata"
    static let LOGIN_TYPE                       = "logintype"
    static let ENC_KEY                          = "MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA6Io1wid+ens+ottXxAGNiYDL+UfSfQb1f4zKpr2tsY7vZO02hgYNjJn+44CCg0RwR9snD1k2q+ELgo9KrYQGRJikIfu8iQEPMyVH4DocNXNtOlgB2QyX5kney8atEGM3BDcQLgjbQlXK3f3aoZ9OI+jutVfkInQ/A/DwSbkIdKlu3MIB2DSTBuP46/1xblEORhkUwh+A5wW/alL4rf0K63RU+gAJZLLV23CWO38RJ2PG6A4ySV200KGltGj8lhtbCsPwMWeqnm9VJRht5Yu6WtqQy9hDdbddTtxkPcFPvFnVhMxcPIt/PkSxD0Ch5OBTecWWuXPka0gG/aNOAvrf/dTYY2Yv3IkVr+US5ctXg7wNwTrdMpYtAnZ+7IbBdDiHUhj3negqmq8dxtmsQ/r15MNNitPHi+MV0svVUsOCPxsSCcDo46duvhesyM9KVTVHrU8OpKXgIQvGO0pkh1rznbHFwnI4LQStuA2hvudRMR9K14jLqKxng+CBSQS2JDrIBzb/ufVBCmgzntxWujDwczULKyff10TeYLItrsuAFDTPr+rwzm2A7rr1iKinzvS+WziqhgyFw1eo2bPmUc9CQV9ykk7XfyJKmUBtnXP7hnAR4AcZlvKcnD0DI/OOB+b0BxFxs0wgv21SK1r10AOvG9dLAnxZZWmWg4alHxLRnjMCAwEAAQ=="
    
   static let SOAP_ENV_BEGIN =  "<?xml version='1.0' encoding='utf-8'?> <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'> <soap:Header> <AuthHeader xmlns='http://askaribank.com.pk/'>"
    
//   static let SOAP_ENV_MID =  "</AuthHeader> </soap:Header> <soap:Body> <DataManagerECRP xmlns='http://askaribank.com.pk/'>"
    
    static let SOAP_ENV_MID =  "</AuthHeader> </soap:Header> <soap:Body> <DataManagerIOSECRP xmlns='http://askaribank.com.pk/'>"

    
//   static let SOAP_ENV_MID_USER_REG =  "</AuthHeader> </soap:Header> <soap:Body> <UserRegistration xmlns='http://askaribank.com.pk/'>"
    static let SOAP_ENV_MID_USER_REG =  "</AuthHeader> </soap:Header> <soap:Body> <UserRegistrationIOS xmlns='http://askaribank.com.pk/'>"

//   static let SOAP_ENV_END = "</DataManagerECRP></soap:Body></soap:Envelope>"
    static let SOAP_ENV_END = "</DataManagerIOSECRP></soap:Body></soap:Envelope>"

//   static let SOAP_ENV_END_USER_REG = "</UserRegistration></soap:Body></soap:Envelope>"
    static let SOAP_ENV_END_USER_REG = "</UserRegistrationIOS></soap:Body></soap:Envelope>"

    
  
    //MP: The following are SOAP Actions
//    static let SOAP_ACTION                      = "http://askaribank.com.pk/DataManagerECRP"
    static let SOAP_ACTION                      = "http://askaribank.com.pk/DataManagerIOSECRP"

//    static let SOAP_ACTION_USER_REG             = "http://askaribank.com.pk/UserRegistration"
    static let SOAP_ACTION_USER_REG             = "http://askaribank.com.pk/UserRegistrationIOS"

    static let LOGIN_ACTION                     = "LoginMobile"
    static let LOGIN_ACTION_FP                  = "LoginMobileFP"
    static let USER_REGISTRATION                = "UserRegistration"
    static let AUTH_HEADER_TOKEN                = "l8xRrMcnGs3e50KfiHxR7Q=="
    static let AUTH_HEADER_PASS                 = "KwYsEU7D+q2Tg4MuozzRjsG+ScsVSPsskX2eJ8R4vEk="

    static let VERIFY_ACTION                    = "VerifySMS"
    static let PAN_ACTION                       = "GetAccountsFromPANs"
    static let MINI_STATEMENT                   = "GetMiniStatment"
    static let GET_FUNDS_TRANSFER_DETAIL        = "GetFundTransferDetails"
    static let FUNDS_TRANSFER_VALIDATION        = "FundsTransferAccountValidation"
    static let NEW_ACCOUNT_VALIDATION           = "FundsTransferToOwnNewAccountValidation"
    static let OTHER_NEW_ACCOUNT_VALIDATION     = "FundsTransferToOtherNewAccountValidation"
    static let VALIDATE_FPIN                    = "ValidateFinancialPin"
    static let CHANGE_PASSWORD                  = "ChangePasswordValidation"
    static let GET_DAILY_LIMIT                  = "GetCustomerDailyLimit"
    static let NEW_LIMIT_VALIDATION             = "ChangeCustomerDailyLimitValidation"
    static let CUSTOMER_DAILY_LIMIT             = "ChangeCustomerDailyLimitDone"
    static let FINANCIAL_PIN                    = "GenerateFinancialPIN"
    static let GET_CREDIT_CARD_LIST             = "GetCreditCards"
    static let BILL_COMPANY_TYPES               = "GetBillPaymentCompanyTypes"
    static let GET_PAYMENT_COMPANIES            = "GetPaymentCompanies"
    static let GET_PROMOTIONS                   = "GetPromotions"
    static let GET_BILL_PAYMENT_LIST            = "GetBillPaymentList"
    static let BILL_INQUIRY_NEW                 = "BillInquiryNew"
    static let BILL_INQUIRY_NEW_DONE            = "BillInquiryNewDone"
    static let GET_TRANSPORT_SERVICE            = "GetTransportServices"
    static let GET_DEPARTURE_CITY               = "GetTransportDepartureCity"
    static let GET_ARRIVAL_CITY                 = "GetTransportArrivalCity"
    static let LOGOUT                           = "Logout"
    static let GET_BUS_TIMES                    = "GetTransportServiceTimes"
    static let VALIDATE_TRANSPORT_SEAT          = "SetTransportSeatValidationStep1"
    static let GET_SEAT_PLAN                    = "GetTransportSeatPlan"
    static let CARDLESS_AMOUNT_LIMIT            = "GetCardlessAmountLimits"
    static let VOUCHER_GENERATION               = "CardlessWithdrawalVoucherGeneration"
    static let CARDLESS_ACCOUNT_VALIADTION      = "CardlessWithdrawalAccountValidation"
    static let CUSTOMER_CARD_STATUS_INQUIRY     = "DoCustomerCardStatusInquiry"
    static let CARD_STATUS_CHANGE               = "CardStatusChange"
    static let FPIN_FOR_ATM_STATUS              = "ATMCardStatusChangeOTP"
    static let ATM_LOCATION                     = "GetATMLocations"
    static let GET_CINEMA_CITIES                = "GetCinemaCitites"
    static let GET_CINEMA_LIST                  = "GetCinemaList"
    static let GET_CINEMA_MOVIES                = "GetMovieList"
    static let GET_MOVIE_DATE_LIST              = "GetMovieDateList"
    static let GET_MOVIE_TIME                   = "GetMovieTimes"
    static let VALIDATE_TRANSPORT_SEAT_STEP2    = "SetTransportSeatValidationStep2"
    static let VALIDATE_TRANSPORT_SEAT_DONE     = "SetTransportSeatValidationDone"
    static let GET_LOANS                        = "GetLoans"
    static let GET_LOAN_DETAILS                 = "GetLoansDetails"
    static let GET_CINEMA_SEAT_PLAN             = "GetMovieSeatPlan"
    static let VALIDATE_CINEMA_SEAT_STEP1       = "SetCinemaSeatValidationStep1"
    static let VALIDATE_CINEMA_SEAT_STEP2       = "SetCinemaSeatValidationStep2"
    static let VALIDATE_CINEMA_SEAT_DONE        = "SetCinemaSeatValidationDone"
    static let PAID_DEPOSIT_CHEQUE              = "GetPaidAndDepositCheques"
    static let REQUEST_CHECQUE_BOOK             = "OrderChequebookConfirm"
    static let SEND_OTP_REQUEST                 = "SendOTP"
    static let GET_ALL_CHECQUE_BOOK_LIST        = "GetAllChequebookList"
    static let GET_CHEQUE_DETAILS               = "GetChequeDetails"
    static let STOP_CHEQUE_REQUEST              = "StopChequeDone"
    static let CHEQUE_BOOK_REQUEST              = "OrderChequebookRequest"
    static let CREDIT_CARD_VALIDATION           = "CreditCardAccountValidation"
    static let CARD_PAYMENT_DONE                = "CreditCardPaymentDone"
    static let USER_FINGER_PRINT_LOGIN          = "UpdateUserFingerLogin"
    static let FUND_TRANSFER_OWN                = "FundsTransferToOwnAccountDone"
    static let FUND_TRANSFER_OTHER              = "FundsTransferToOtherAccountDone"
    static let REWARD_POINTS                    = "GetATMrewardPoints"
    static let DELINK_ACCOUNTS                  = "DeLinkAccounts"
    static let GET_ACCOUNT_STATEMENT            = "GetAccountStatment"
    static let CHECK_EMAIL_ALERT_STATUS         = "CheckEmailAlertStatus"
    static let UPDATE_EMAIL_STATUS              = "UpdateEmailAlertStatus"
    static let GET_CVM_BRANCHES                 = "GetCVMBranches"
    static let GET_CVM_SERVICE                  = "GetCVMServicesOnBranchInfo"
    static let GET_CVM_AVAILABILITY_DATE        = "GetCVMAvailableDaysToTakeAppointment"
    static let GET_CVM_AVAILABILITY_TIME        = "GetCVMDayAvailableTimesToTakeAppointment"
    static let CVM_TAKE_APPOINTMENT             = "CVMTakeAppointment"
    static let GET_CVM_APPOINTMENTS             = "GetCVMCustomerAppointments"
    static let GET_CREDIT_CARD_STATEMENT        = "GetCreditCardStatement"
    static let GET_CUST_MESSAGE                 = "GetCustMessages"
    static let GET_CUST_STATUS_INQUIRY          = "DoCustomerCardStatusInquiry"
    static let GET_INTL_TRANS_WINDOW            = "GetInternationalTransactionWindows"
    static let ACTIVATE_INTL_TRAN_WIN           = "ActivateCustomerInternationalWindow"
    static let DEACTIVATE_INTL_TRAN_WIN         = "DeleteCustomerInternationalTransaction"
    static let GET_FT_LIMIT_CNIC                = "GetFundTransferLimitDataByCnic"
    static let UPDATE_FUND_LIMIT_CNIC           = "UpdateFundTransferLimitDataByCnic"
    static let GET_CASH_WITHDRAWAL_BY_CARD      = "GetCashWithdrawalLimitByCardId"
    static let UPDATE_CASH_WITHDRAWAL_BY_CARD   = "UpdateCashWithdrawalLimitByCardId"
    static let GET_POS_LIMIT_BY_CARD            = "GetPOSLimitDataByCardId"
    static let UPDATE_POS_LIMIT_BY_CARD         = "UpdatePOSLimitDataByCardId"
    static let GET_FT_LIMIT_BY_CNIC             = "GetFundTransferLimitDataByCnic"
    static let CUSTOMER_DAILY_LIMIT_BY_CNIC     = "UpdateFundTransferLimitDataByCnic"
    static let CHANGE_CARD_PIN                  = "ATMCardPinChanged"

    static let LINKED_ACCOUNT_FT                = "http://akbl.com.pk/GetLinkedAccountsFT"
    static let LINKED_ACCOUNT_IBFT              = "http://akbl.com.pk/GetLinkedAccountsIBFT"
    static let OWN_ACCOUNT_OLD_VALIDATION       = "http://akbl.com.pk/FundsTransferToOwnOldAccountValidation"
    static let OTHER_OLD_ACCOUNT_VALIDATION     = "http://akbl.com.pk/FundsTransferToOtherOldAccountValidation"
    static let BANK_LIST                        = "http://akbl.com.pk/GetIBFTBanks"
    static let GET_CARD_HISTORY                 = "http://akbl.com.pk/GetCardStatusHistory"
    
    
    static let STATUS_BAR_COLOR_CODE            = "#319461"
    static let SUCCESS_CODE                     = "00"
    static let INTERNAL_ERROR                   = "11"
    static let SESSION_EXPIRED                  = "88"
    static let SERVER_ERROR                     = "99"
    static let APP_UPDATE_ERROR                 = "22"
    
    /*****************************************************************************/
    //
    /*****************************************************************************/

    enum datePickerType : Int {
        case  eDatePickerNone = 0, eDatePickerFrom, eDatePickerTo
    }
    
    enum IntlPickerType : Int {
        case  ePickerNone = 0, ePickerStartDate, ePickerStartTime,ePickerEndDate,ePickerEndTime
    }
    
    enum selectedTab : Int {
        case none   = 0, home, stories, search, traffic, more
    }
    
    enum selectedHomeTab : Int {
        case eTab_None   = 0, eTab_IFSC, eTab_QR, eTab_Menu
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/

    static func correctOrrientationOfImage(_ img:UIImage) -> UIImage {
        
        if (img.imageOrientation == UIImage.Orientation.up) {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
        
    }
        
    /*****************************************************************************/
    //
    /*****************************************************************************/

    static func addShadowView(viewForShadow:UIView, tag:Int) {
        
        for view in (viewForShadow.superview?.subviews)! {
            if view.tag == tag {
                view.removeFromSuperview()
            }
        }
        
        //Create new shadow view with frame
        let shadowView = UIView(frame: viewForShadow.frame)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 3)
        shadowView.layer.masksToBounds = false
        
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowPath = UIBezierPath(rect: viewForShadow.bounds).cgPath
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowView.layer.shouldRasterize = true
        shadowView.tag = tag
        
        viewForShadow.superview?.insertSubview(shadowView, belowSubview: viewForShadow)
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/

    static func getScreenAdjustedImageRect (maxSize:CGSize, image:UIImage) -> CGSize {
        
        // Calculate the image ratio
        // resize it to
        var imgSize = image.size
        
        if imgSize.width > imgSize.height
        {
            let dividant = imgSize.width / maxSize.width;
            imgSize.height = imgSize.height / dividant;
            imgSize.width = maxSize.height;
        }
        else
        {
            let dividant = imgSize.height / maxSize.height;
            imgSize.width = imgSize.width / dividant;
            imgSize.height = maxSize.height;
        }
        
        return imgSize
    }

    /*****************************************************************************/
    // We Pop to Login screen from here
    /*****************************************************************************/
    
    static func popToLoginController ()
    {
        
    }
    
    /*****************************************************************************/
    //
    /*****************************************************************************/

    static func encrypt(plainString: String, publicKey: String?) -> String?  {
        
        let keyData = Data(base64Encoded: publicKey!)!
        let key = SecKeyCreateWithData(keyData as NSData, [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate,
        ] as NSDictionary, nil)
        
        let algorithm : SecKeyAlgorithm = .rsaSignatureRaw

        var error: Unmanaged<CFError>?
        let cipherText = SecKeyCreateEncryptedData(key!,
                                                         algorithm,
                                                         plainString as! CFData,
                                                         &error)
        
        return  String(data: ((cipherText! as CFData) as Data), encoding: String.Encoding.utf8) as String?
    }
    
}

