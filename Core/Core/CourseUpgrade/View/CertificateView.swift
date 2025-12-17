//
//  CertificateView.swift
//  Core
//
//  Created by Sumanta Roy on 04/12/25.
//

import SwiftUI
import Theme

struct CertificateView: View {
    var name: String
    var courseName: String
    
    var body: some View {
        ZStack {
            CoreAssets.certificateBg.swiftUIImage
                .resizable()
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Theme.Colors.accentColor.opacity(0.2), lineWidth: 1)
                )
                            
            Text(CoreLocalization.CertificateView.watermark)
                .font(Theme.Fonts.custom(.bold, 50.0))
                .foregroundColor(.gray)
                .opacity(0.2)
                .rotationEffect(.degrees(-45))
                .offset(x: 0, y: 0)
            
            HStack(alignment: .top) {
                // Left Column
                VStack(alignment: .leading) {
                    CoreAssets.verifiedCertificate.swiftUIImage
                        .resizable()
                        .frame(width: 70.0, height: 28.0)
                        .foregroundStyle(.black)
                    Spacer()
                    VStack(alignment: .leading, spacing: 5.0, content: {
                        Text(CoreLocalization.CertificateView.title)
                            .font(Theme.Fonts.custom(.regular, 8))
                            .foregroundStyle(Theme.Colors.certificateTextGrey)
                        Text(name)
                            .font(Theme.Fonts.custom(.bold, 22))
                            .foregroundStyle(Theme.Colors.certificateTitleTextColor)
                        
                        Text(CoreLocalization.CertificateView.titleCompleted)
                            .font(Theme.Fonts.custom(.regular, 8))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .foregroundStyle(Theme.Colors.certificateTextGrey)
                        
                        Text(courseName)
                            .font(Theme.Fonts.custom(.bold, 18))
                            .foregroundStyle(Theme.Colors.certificateTitleTextColor)
                        
                        Text(CoreLocalization.CertificateView.courseOffered)
                            .font(Theme.Fonts.custom(.regular, 8))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                            .foregroundStyle(Theme.Colors.certificateTextGrey)
                    })
                    
                    Spacer()
                    HStack {
                        HStack {
                            ThemeAssets.appLogo.swiftUIImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 57.0, maxHeight: 41.0)
                                .colorMultiply(.black)
                        }
                        HStack(spacing: 10.0) {
                            VStack(alignment: .leading) {
                                Text(CoreLocalization.CertificateView.verified)
                                    .font(Theme.Fonts.custom(.regular, 6))
                                    .foregroundStyle(Theme.Colors.certificateTextGrey)
                                Text(CoreLocalization.CertificateView.issued)
                                    .font(Theme.Fonts.custom(.regular, 6))
                                    .foregroundStyle(Theme.Colors.certificateLightTextColor)
                            }
                            VStack(alignment: .leading) {
                                Text(CoreLocalization.CertificateView.validityTitle)
                                    .font(Theme.Fonts.custom(.regular, 6))
                                    .foregroundStyle(Theme.Colors.certificateTextGrey)
                                Text(CoreLocalization.CertificateView.certificateId)
                                    .font(Theme.Fonts.custom(.regular, 6))
                                    .foregroundStyle(Theme.Colors.certificateLightTextColor)
                            }
                        }
                    }
                }
                .padding(.leading, 10)
                .padding(.top, 30)
                
                // Right Column
                VStack(alignment: .trailing, spacing: 20) {
                    Spacer()
                    Image(systemName: "globe")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.black)
                    
                    VStack(alignment: .trailing, spacing: 10.0) {
                        VStack(alignment: .trailing) {
                            CoreAssets.signatureCertificate.swiftUIImage
                                .padding(.bottom, 5)
                                .foregroundStyle(.black)
                            Text("Maurilio Pugliesi")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateTextGrey)
                            Text("Professor")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateLightTextColor)
                            Text("University X")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateLightTextColor)
                            
                        }
                        
                        VStack(alignment: .trailing) {
                            CoreAssets.signatureCertificate.swiftUIImage
                                .padding(.bottom, 5)
                                .foregroundStyle(.black)
                            Text("Justine Doe, Ph.D.")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateTextGrey)
                            Text("Professor")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateLightTextColor)
                            Text("University X")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateLightTextColor)
                        }
                        
                        VStack(alignment: .trailing) {
                            CoreAssets.signatureCertificate.swiftUIImage
                                .padding(.bottom, 5)
                                .foregroundStyle(.black)
                            Text("Helga Svobodová")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateTextGrey)
                            Text("Professor")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateLightTextColor)
                            Text("University X")
                                .font(Theme.Fonts.custom(.regular, 8))
                                .foregroundStyle(Theme.Colors.certificateLightTextColor)
                        }
                    }
                    Spacer()
                }
                .padding(.trailing, 10)
                .padding(.leading, 10)
            }
        }
    }
}
