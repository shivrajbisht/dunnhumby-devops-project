resource "aws_key_pair" "dunnhumby-ssb" {
  key_name   = "dunnhumby-ssb"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbjFZGOKEnhgAHPozd+ibcAAlNboaweFZBEVj/xAxWYNrswyDsyS8B/ZCCjZyE/m3EK7+3KpfnUMao5VBJP64hhULqyyt+eMOXRjUXbbfYeCPq+P5b69dZx7ho5nXlideENbHSuzd0AN4JPekQCR8wv5kN+g+/+8sgg2XPx43dlZ4quFD4Ek1078wXEBMiVu91z+phnpmaHPEiA84Kug9mjzKkYWmzsBK3kM8XBAqqGP59mYNW0h5mjbe34TR0G0jh5WWBiPNYKe2sJtp6Loc+EhVT4i8lY39UkfcuSdM4eonJrhjMlIysigMGD/b2p5yvolAlCPBPbrrJIUM4fV4KEOB+ScnQx62XKjPsviojaVobwJu1BR0oXa56POYpWCJgkZOyKLDTEMLrIeg/6XEXfT3vhSNjDXiXMTFUD0tzeb0ecuOWFdcCmvVrYnB/qIU+Jsl8Db6+uUrhYpY6L5FyBLqagXJlGzHE+RelMOZB53goLVvKhGZTt4PGkij+mHiT6IvsG4y8Z9BqG07ivIPN9vniySe4LJ0Ctxyi+3clx72Q3BtJoesjj01P6/JAWMzSoPQOnjumyk+bE8kGTmeSbBB5L3db+Sb5fnKA6Q1XDrkhp9673e5ILULiNfKVjol/jkgcbQPXRey/pHGPj96p1HFOQiv0vtWavGbL/0dDUw== shivraj.bisht@cosmosis.org"
}

resource "aws_instance" "dh-datapipeline" {
    ami = "${var.instance_ami_name}"
    instance_type = "t2.small"
    key_name = "${var.aws_key_name}"
    availability_zone = "${var.az}"
    vpc_security_group_ids = ["${aws_security_group.dunnhumby-sg.id}"]
    subnet_id = "${aws_subnet.dunnhumby-subnet-public.id}"
    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.dunnhumby_profile.id
    tags = {
        Name = "dh-datapipeline"
    }
}

resource "null_resource" "copy_execute" {

    connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
    host        = aws_instance.dh-datapipeline.public_ip
  }

    provisioner "file" {
    source      = "files/scripts.sh"
    destination = "/tmp/scripts.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/scripts.sh",
        "sudo bash /tmp/scripts.sh"
      ]
    }
    depends_on = [ aws_instance.dh-datapipeline ]
}