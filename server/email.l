unit nodemailer
	object transporter
	js void setup
		const nodemailer = require("nodemailer");
		mail_transporter = nodemailer.createTransport({
			service: 'gmail',
			auth: {
				user: "heiko.weible",
				pass: ""
			},
		});
		let info = await mail_transporter.sendMail({
			from: "Lunchtime Games<heiko.weible@googlemail.com>",
			to: "tina@visual-generation.de",
			subject: "Hello Subject",
			text: "Hello world Text",
			html: "<b>Hello world HTML</b>",
		});
		log(info)
		
unit mail
	object aws, ses
	
	async js void setup
		try {
			mail_aws = await import("@aws-sdk/client-ses");
			mail_ses = new mail_aws.SESClient({ region: "eu-central-1" })
		} catch (error) {
			console.error(error)
		}

	js async string sendEmail: string from
		                       string to
		                       string subject
		                       string message
		if(Platform_isDebug) return "preview"
		try {
			let result = await mail_ses.send(new mail_aws.SendEmailCommand({
				Source: from,
				Destination: { /* required */
					ToAddresses: [to]
				},
				Message: { /* required */
					Body: { /* required */
						Html: {
							Charset: "UTF-8",
							Data: message
						}
					},
					Subject: {
						Charset: 'UTF-8',
						Data: subject
					}
				}
			}))
			console.log(result.$metadata.httpStatusCode)
			return result.$metadata.httpStatusCode
		}
		catch (err) {
			return err.toString()
		}

	
	
		
		
