//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Coenttb_Web
import Identities
import Mailgun

public enum PasswordEmail {
    case reset(PasswordEmail.Reset)
    case change(PasswordEmail.Change)
}

extension PasswordEmail {
    public enum Reset {
        case request(PasswordEmail.Reset.Request)
        case confirmation(PasswordEmail.Reset.Confirmation)
    }

    public enum Change {
        case notification(PasswordEmail.Change.Notification)
    }
}

extension PasswordEmail.Reset {
    public struct Request: Sendable {
        public let resetUrl: URL
        public let userName: String?
        public let userEmail: EmailAddress

        public init(resetUrl: URL, userName: String?, userEmail: EmailAddress) {
            self.resetUrl = resetUrl
            self.userName = userName
            self.userEmail = userEmail
        }
    }

    public struct Confirmation: Sendable {
        public let userName: String?
        public let userEmail: EmailAddress

        public init(userName: String?, userEmail: EmailAddress) {
            self.userName = userName
            self.userEmail = userEmail
        }
    }
}

extension PasswordEmail.Change {
    public struct Notification: Sendable {
        public let userName: String?
        public let userEmail: EmailAddress

        public init(userName: String?, userEmail: EmailAddress) {
            self.userName = userName
            self.userEmail = userEmail
        }
    }
}

extension Email {
    public init(
        business: BusinessDetails,
        passwordEmail: PasswordEmail
    ) {
        switch passwordEmail {
        case .reset(let reset):
            switch reset {
            case .request(let request):
                self = .init(
                    business: business,
                    passwordResetRequest: request
                )
            case .confirmation(let confirmation):
                self = .init(
                    business: business,
                    passwordResetConfirmation: confirmation
                )
            }
        case .change(let change):
            switch change {
            case .notification(let notification):
                self = .init(
                    business: business,
                    passwordChangeNotification: notification
                )
            }
        }
    }
}

extension Email {
    private init(
        business: BusinessDetails,
        passwordResetRequest: PasswordEmail.Reset.Request
    ) {
        let html = TableEmailDocument(
            preheader: TranslatedString(
                dutch: "Reset je wachtwoord voor \(business.name)",
                english: "Reset your password for \(business.name)"
            ).description
        ) {
            tr {
                td {
                    VStack(alignment: .leading) {
                        Header(3) {
                            TranslatedString(
                                dutch: "Reset je wachtwoord",
                                english: "Reset your password"
                            )
                        }

                        CoenttbHTML.Paragraph {
                            TranslatedString(
                                dutch: "We hebben een verzoek ontvangen om het wachtwoord voor je \(business.name) account te resetten. Klik op de onderstaande knop om je wachtwoord te wijzigen.",
                                english: "We received a request to reset the password for your \(business.name) account. Click the button below to change your password."
                            )
                        }
                        .padding(bottom: .extraSmall)
                        .font(.body)

                        Link(href: .init(passwordResetRequest.resetUrl.absoluteString)) {
                            TranslatedString(
                                dutch: "Reset wachtwoord",
                                english: "Reset password"
                            )
                        }
                        .color(.text.primary.reverse())
                        .padding(bottom: .medium)

//                        Button(
//                            tag: a,
//                            background: business.primaryColor
//                        ) {
//                            TranslatedString(
//                                dutch: "Reset wachtwoord",
//                                english: "Reset password"
//                            )
//                        }
//                        .color(.text.primary.reverse())
//                        .href(passwordResetRequest.resetUrl.absoluteString)
//                        .padding(bottom: Length.medium)

                        CoenttbHTML.Paragraph(.small) {
                            TranslatedString(
                                dutch: "Om veiligheidsredenen verloopt deze link binnen 1 uur. ",
                                english: "This link will expire in 1 hour for security reasons. "
                            )

                            TranslatedString(
                                dutch: "Als je geen wachtwoordreset hebt aangevraagd, kun je deze e-mail negeren.",
                                english: "If you didn't request a password reset, you can ignore this email."
                            )

                            br()

                            TranslatedString(
                                dutch: "Voor hulp, neem contact op met ons op via \(business.supportEmail).",
                                english: "For help, contact us at \(business.supportEmail)."
                            )
                        }
                        .font(.footnote)
                        .color(.text.secondary)
                    }
                    .padding(vertical: .small, horizontal: .medium)
                }
            }
        }
            .backgroundColor(.background.primary.reverse())

        let bytes: ContiguousArray<UInt8> = html.render()
        let string: String = String(decoding: bytes, as: UTF8.self)

        let subjectAdd = TranslatedString(
            dutch: "Reset je wachtwoord",
            english: "Reset your password"
        )

        self.init(
            from: business.fromEmail,
            to: [
                passwordResetRequest.userEmail
            ],
            subject: "\(business.name) | \(subjectAdd)",
            html: string,
            text: nil
        )
    }

    private init(
        business: BusinessDetails,
        passwordResetConfirmation: PasswordEmail.Reset.Confirmation
    ) {
        let html = TableEmailDocument(
            preheader: TranslatedString(
                dutch: "Je wachtwoord is succesvol gereset voor \(business.name)",
                english: "Your password has been successfully reset for \(business.name)"
            ).description
        ) {
            tr {
                td {
                    VStack(alignment: .leading) {
                        Header(3) {
                            TranslatedString(
                                dutch: "Wachtwoord succesvol gereset",
                                english: "Password Successfully Reset"
                            )
                        }

                        CoenttbHTML.Paragraph {
                            TranslatedString(
                                dutch: "We bevestigen dat je wachtwoord voor je \(business.name) account succesvol is gereset.",
                                english: "We confirm that the password for your \(business.name) account has been successfully reset."
                            )
                        }
                        .padding(bottom: .extraSmall)
                        .font(.body)

                        CoenttbHTML.Paragraph {
                            TranslatedString(
                                dutch: "Je kunt nu inloggen met je nieuwe wachtwoord.",
                                english: "You can now log in using your new password."
                            )
                        }
                        .padding(bottom: .extraSmall)
                        .font(.body)

                        CoenttbHTML.Paragraph(.small) {
                            TranslatedString(
                                dutch: "Als je deze wijziging niet hebt aangevraagd, neem dan onmiddellijk contact op met ons via \(business.supportEmail) om je account te beveiligen.",
                                english: "If you didn't request this change, please contact us immediately at \(business.supportEmail) to secure your account."
                            )
                        }
                        .font(.footnote)
                        .color(.text.secondary)
                    }
                    .padding(vertical: .small, horizontal: .medium)
                }
            }
        }
            .backgroundColor(.background.primary.reverse())

        let bytes: ContiguousArray<UInt8> = html.render()
        let string: String = String(decoding: bytes, as: UTF8.self)

        let subjectAdd = TranslatedString(
            dutch: "Wachtwoord succesvol gereset",
            english: "Password Successfully Reset"
        )

        self.init(
            from: business.fromEmail,
            to: [
                passwordResetConfirmation.userEmail
            ],
            subject: "\(business.name) | \(subjectAdd)",
            html: string,
            text: nil
        )
    }

    private init(
        business: BusinessDetails,
        passwordChangeNotification: PasswordEmail.Change.Notification
    ) {
        let html = TableEmailDocument(
            preheader: TranslatedString(
                dutch: "Je wachtwoord is gewijzigd voor \(business.name)",
                english: "Your password has been changed for \(business.name)"
            ).description
        ) {
            tr {
                td {
                    VStack(alignment: .leading) {
                        Header(3) {
                            TranslatedString(
                                dutch: "Wachtwoord gewijzigd",
                                english: "Password Changed"
                            )
                        }

                        CoenttbHTML.Paragraph {
                            TranslatedString(
                                dutch: "We willen je informeren dat het wachtwoord voor je \(business.name) account zojuist is gewijzigd.",
                                english: "We're writing to inform you that the password for your \(business.name) account has just been changed."
                            )
                        }
                        .padding(bottom: .extraSmall)
                        .font(.body)

                        CoenttbHTML.Paragraph {
                            TranslatedString(
                                dutch: "Als je deze wijziging hebt aangevraagd, kun je deze e-mail als bevestiging beschouwen.",
                                english: "If you requested this change, please consider this email as confirmation."
                            )
                        }
                        .padding(bottom: .extraSmall)
                        .font(.body)

                        CoenttbHTML.Paragraph(.small) {
                            TranslatedString(
                                dutch: "Als je deze wijziging niet hebt aangevraagd, neem dan onmiddellijk contact op met ons via \(business.supportEmail) om je account te beveiligen.",
                                english: "If you didn't request this change, please contact us immediately at \(business.supportEmail) to secure your account."
                            )
                        }
                        .font(.footnote)
                        .color(.text.secondary)
                    }
                    .padding(vertical: .small, horizontal: .medium)
                }
            }
        }
            .backgroundColor(.background.primary.reverse())

        let bytes: ContiguousArray<UInt8> = html.render()
        let string: String = String(decoding: bytes, as: UTF8.self)

        let subjectAdd = TranslatedString(
            dutch: "Belangrijk: Je wachtwoord is gewijzigd",
            english: "Important: Your password has been changed"
        )

        self.init(
            from: business.fromEmail,
            to: [
//                passwordChangeNotification.userName.map { name in "\(name) <\(passwordChangeNotification.userEmail.rawValue)>" } ?? "\(passwordChangeNotification.userEmail.rawValue)"
                passwordChangeNotification.userEmail
            ],
            subject: "\(business.name) | \(subjectAdd)",
            html: string,
            text: nil
        )
    }
}
