//
//  File.swift
//  coenttb-identities
//
//  PasswordResetd by Coen ten Thije Boonkkamp on 20/09/2024.
//

import Coenttb_Web
import Foundation
import Identities

extension Identity.Consumer.View.Password.Reset {
    package struct Request: HTML {
        let formActionURL: URL
        let homeHref: URL
        let primaryColor: HTMLColor

        package init(
            formActionURL: URL,
            homeHref: URL,
            primaryColor: HTMLColor
        ) {
            self.formActionURL = formActionURL
            self.homeHref = homeHref
            self.primaryColor = primaryColor
        }

        private static var pagemodule_forgot_password_id: String { "pagemodule_forgot_password_id" }

        package var body: some HTML {
            PageModule(theme: .login) {

                VStack {
                    CoenttbHTML.Paragraph {
                        TranslatedString(
                            dutch: "Voer uw e-mailadres in en we sturen u een link om uw wachtwoord opnieuw in te stellen.",
                            english: "Enter your email address and we will send you a link to reset your password."
                        )
                    }
                    .font(.body(.small))
                    .textAlign(.center)
                    .color(.text.secondary)

                    form(
                        action: .init(self.formActionURL.relativePath),
                        method: .post
                    ) {
                        VStack {
                            Input(
                                codingKey: Identity.Password.Reset.Request.CodingKeys.email,
                                type: .email(
                                    .init(
                                        placeholder: .init("Email")
                                    )
                                )
                            )
                            .focusOnPageLoad()

                            Button(
                                button: .init(type: .submit)
                            ) {
                                TranslatedString(
                                    dutch: "Reset link versturen",
                                    english: "Send Reset Link"
                                )
                            }
                            .color(.text.primary.reverse())
                            .width(.percent(100))
                            .justifyContent(.center)

                            Link(href: .init(homeHref.relativePath)) {
                                TranslatedString(
                                    dutch: "Terug naar home",
                                    english: "Back to Home"
                                ).description
                            }
                            .linkColor(self.primaryColor)
                            .fontWeight(.medium)
                            .font(.body(.small))
                            .textAlign(.center)
                        }
                    }
                    .id("form-forgot-password")
                }
                .width(.percent(100))
                .maxWidth(.rem(20))
                .maxWidth(.rem(24), media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    TranslatedString(
                        dutch: "Wachtwoord vergeten",
                        english: "Reset Password"
                    )
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
            .id(Self.pagemodule_forgot_password_id)

            script {"""
            document.addEventListener('DOMContentLoaded', function() {
                const form = document.getElementById('form-forgot-password');
                form.addEventListener('submit', async function(event) {
                    event.preventDefault();
                    const formData = new FormData(form);
                    try {
                        const response = await fetch(form.action, {
                            method: form.method,
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                                'Accept': 'application/json'
                            },
                            body: new URLSearchParams(formData).toString()
                        });
                        const data = await response.json();
                        if (data.success) {
                            const pageModule = document.getElementById("\(Self.pagemodule_forgot_password_id)");
                            pageModule.outerHTML = \(html: Identity.Consumer.View.Password.Reset.Request.ConfirmReceipt(homeHref: self.homeHref, primaryColor: self.primaryColor));
                        } else {
                            throw new Error(data.message || '\(TranslatedString(
                                dutch: "Verzoek om wachtwoord te resetten mislukt",
                                english: "Password reset request failed"
                            ))');
                        }
                    } catch (error) {
                        console.error("Error occurred:", error);
                        alert('\(TranslatedString(
                            dutch: "Er is een fout opgetreden. Probeer het later opnieuw.",
                            english: "An error occurred. Please try again later."
                        ))');
                    }
                });
            });
            """}
        }
    }
}

extension Identity.Consumer.View.Password.Reset.Request {
    struct ConfirmReceipt: HTML {
        let homeHref: URL
        let primaryColor: HTMLColor

        init(
            homeHref: URL,
            primaryColor: HTMLColor
        ) {
            self.homeHref = homeHref
            self.primaryColor = primaryColor
        }

        package var body: some HTML {
            PageModule(theme: .login) {
                VStack {
                    CoenttbHTML.Paragraph {
                        TranslatedString(
                            dutch: "We hebben een e-mail verstuurd met instructies om uw wachtwoord opnieuw in te stellen.",
                            english: "We've sent an email with instructions to reset your password."
                        )
                    }
                    .textAlign(.center)
                    .margin(bottom: .rem(1))

                    CoenttbHTML.Paragraph {
                        TranslatedString(
                            dutch: "Als u de e-mail niet binnen enkele minuten ontvangt, controleer dan uw spam-folder.",
                            english: "If you don't receive the email within a few minutes, please check your spam folder."
                        )
                    }
                    .textAlign(.center)
                    .margin(bottom: .rem(2))

                    Link(href: .init(homeHref.relativePath)) {
                        TranslatedString(
                            dutch: "Terug naar home",
                            english: "Back to Home"
                        ).description
                    }
                    .linkColor(self.primaryColor)
                }
                .textAlign(.center)
                .alignItems(.center)
                .width(.percent(100))
                .maxWidth(.rem(20))
                .maxWidth(.rem(24), media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    TranslatedString(
                        dutch: "Verzoek ontvangen",
                        english: "Request Received"
                    )
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
        }
    }
}

extension Identity.Consumer.View.Password.Reset {
    package struct Confirm: HTML {
        let token: String
        let passwordResetAction: URL
        let homeHref: URL
        let redirect: URL
        let primaryColor: HTMLColor

        package init(
            token: String,
            passwordResetAction: URL,
            homeHref: URL,
            redirect: URL,
            primaryColor: HTMLColor
        ) {
            self.token = token
            self.passwordResetAction = passwordResetAction
            self.homeHref = homeHref
            self.redirect = redirect
            self.primaryColor = primaryColor
        }

        private static var passwordResetId: String { "password-reset-id" }

        package var body: some HTML {
            PageModule(theme: .login) {

                VStack {
                    CoenttbHTML.Paragraph {
                        TranslatedString(
                            dutch: "Vul je nieuwe wachtwoord in.",
                            english: "Enter your new password."
                        )
                    }
                    .font(.body(.small))
                    .textAlign(.center)
                    .color(.text.secondary)

                    form(
                        action: .init(self.passwordResetAction.relativePath),
                        method: .post
                    ) {
                        VStack {
                            Input(
                                codingKey: Identity.Password.Reset.Confirm.CodingKeys.newPassword,
                                type: .password(
                                    .init(
                                        placeholder: .init(String.password.capitalizingFirstLetter().description)
                                    )
                                )
                            )
                            .focusOnPageLoad()

                            Button(
                                button: .init(type: .submit)
                            ) {
                                String.continue.capitalizingFirstLetter()
                            }
                            .color(.text.primary.reverse())
                            .width(.percent(100))
                            .justifyContent(.center)

                            Link(href: .init(homeHref.relativePath)) {
                                TranslatedString(
                                    dutch: "Terug naar de homepagina",
                                    english: "Back to home"
                                ).description
                            }
                            .linkColor(self.primaryColor)
                            .fontWeight(.medium)
                            .font(.body(.small))
                            .textAlign(.center)
                        }
                    }
                    .id("form-password-reset")
                }
                .width(.percent(100))
                .maxWidth(.rem(20))
                .maxWidth(.rem(24), media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    String.reset_your_password.capitalizingFirstLetter()
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
            .id(Self.passwordResetId)

            script {"""
               document.addEventListener('DOMContentLoaded', function() {
                   const form = document.getElementById("form-password-reset");
                   const formContainer = form;

                   form.addEventListener('submit', async function(event) {
                       event.preventDefault();

                       const formData = new FormData(form);
                       const password = formData.get('\(Identity.Password.Reset.Confirm.CodingKeys.newPassword.rawValue)');

                       try {

                           const response = await fetch(form.action, {
                               method: form.method,
                               headers: {
                                   'Content-Type': 'application/x-www-form-urlencoded',
                                   'Accept': 'application/json'
                               },
                               body: new URLSearchParams({
                                    \(Identity.Password.Reset.Confirm.CodingKeys.token.rawValue): '\(self.token)',
                                    \(Identity.Password.Reset.Confirm.CodingKeys.newPassword.rawValue): password
                               }).toString()
                           });

                           if (!response.ok) {
                               throw new Error('Network response was not ok');
                           }

                           const data = await response.json();


                           if (data.success) {
                               const pageModule = document.getElementById("\(Self.passwordResetId)");
                               pageModule.outerHTML = \(html: Identity.Consumer.View.Password.Reset.Confirm.Confirm(redirect: self.redirect, primaryColor: self.primaryColor));
                           } else {
                               throw new Error(data.message || '\(TranslatedString(
                                   dutch: "Verzoek om wachtwoord te resetten mislukt",
                                   english: "Password reset request failed"
                               ))');
                           }

                       } catch (error) {
                           console.error('Error:', error);
                           const messageDiv = document.createElement('div');
                           messageDiv.textContent = 'Password reset failed. Please try again.';
                           messageDiv.style.color = 'red';
                           messageDiv.style.textAlign = 'center';
                           messageDiv.style.marginTop = '10px';
                           formContainer.appendChild(messageDiv);
                       }
                   });
               });
            """}
        }
    }
}

extension Identity.Consumer.View.Password.Reset.Confirm {
    package struct Confirm: HTML {
        package let redirect: URL
        package let primaryColor: HTMLColor

        package init(redirect: URL, primaryColor: HTMLColor) {
            self.redirect = redirect
            self.primaryColor = primaryColor
        }

        private static var confirmationId: String { "password-reset-confirmation-id" }

        package var body: some HTML {
            PageModule(theme: .login) {
                VStack {
                    CoenttbHTML.Paragraph {
                        TranslatedString(
                            dutch: "Je wachtwoord is succesvol gewijzigd.",
                            english: "Your password has been successfully changed."
                        )
                    }
                    .font(.body)
                    .textAlign(.center)
                    .color(.text.primary)
                    .margin(bottom: .medium)

                    CoenttbHTML.Paragraph {
                        TranslatedString(
                            dutch: "Je wordt nu doorgestuurd naar de inlogpagina.",
                            english: "You will now be redirected to the login page."
                        )
                    }
                    .font(.body(.small))
                    .textAlign(.center)
                    .color(.text.secondary)
                    .margin(bottom: .large)

                    Link(
                        TranslatedString(
                            dutch: "Klik hier als je niet automatisch wordt doorgestuurd",
                            english: "Click here if you are not automatically redirected"
                        ).description,
                        href: .init(redirect.relativePath)
                    )
                    .linkColor(self.primaryColor)
                    .font(.body(.small))
                    .fontWeight(.medium)
                    .textAlign(.center)
                }
                .width(.percent(100))
                .maxWidth(.rem(20))
                .maxWidth(.rem(24), media: .mobile)
                .margin(horizontal: .auto)
            } title: {
                Header(3) {
                    TranslatedString(
                        dutch: "Wachtwoord Reset Voltooid",
                        english: "Password Reset Complete"
                    )
                }
                .display(.inlineBlock)
                .textAlign(.center)
            }
            .id(Self.confirmationId)

            script {"""
                document.addEventListener('DOMContentLoaded', function() {
                    setTimeout(function() {
                        window.location.href = '\(redirect.relativePath)';
                    }, 5000); // Redirect after 5 seconds
                });
            """}
        }
    }
}
